import Dispatch
import Foundation
import Socket
import PanasonicEasyIPsetupCore
import NetUtils

let cameraBroadcast = Socket.createAddress(for: "255.255.255.255", on: 10670)!

public class Manager {
	let socket: Socket
	
	private var shouldPoll = true
	public private (set) var configurations = Set<CameraConfiguration>()
	
	public var discoveryHandler: ((CameraConfiguration)->Void)?
	public var errorHandler: ((Error)->Void)?
	
	public init(on queue: DispatchQueue = DispatchQueue.global(), errorHandler: ((Error)->Void)? = nil) throws {
		self.errorHandler = errorHandler
		socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
		try socket.udpBroadcast(enable: true)
		queue.async(execute: startPolling)
		try search()
	}
	
	public func search() throws {
		configurations.removeAll(keepingCapacity: true)
		let addresses = Interface
			.allInterfaces()
			.filter {$0.family == .ipv4 && $0.broadcastAddress != nil}
			.compactMap { $0.addressBytes }
		
		for address in addresses {
			let request = CameraConfiguration.discoveryRequest(from: [2,0,0,0,0,0], ipV4address: address)
			try socket.write(
				from: Data(request),
				to: cameraBroadcast
			)
		}
	}
	
	public func set(configuration: CameraConfiguration) throws {
		let address = Interface.allInterfaces()
			.filter {$0.family == .ipv4 && $0.broadcastAddress != nil}
			.compactMap { $0.addressBytes }
			.first ?? [10, 1, 0, 5]
		let request = configuration.reconfigurationRequest(
			sourceMacAddress: [2,0,0,0,0,0],
			sourceIpAddress: address
		)
		try socket.write(
			from: Data(request),
			to: cameraBroadcast
		)
	}
	
	private func notify(configuration: CameraConfiguration) {
		if configurations.insert(configuration).inserted, let handler = discoveryHandler {
			handler(configuration)
		}
	}
	
	private func startPolling() {
		repeat {
			do {
				var data = Data()
				_ = try socket.listen(forMessage: &data, on: 10669)
				let datagram = Array(data)
				if datagram[0..<4] == [0,1,1,0x75] {
					notify(configuration: try CameraConfiguration(datagram: datagram))
				}
			} catch {
				errorHandler?(error)
			}
		} while shouldPoll
	}
	
	deinit {
		shouldPoll = false
		socket.close()
	}
}
