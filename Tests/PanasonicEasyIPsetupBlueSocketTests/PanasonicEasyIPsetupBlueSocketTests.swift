import XCTest
@testable import PanasonicEasyIPsetupBlueSocket

import PanasonicEasyIPsetupCore

final class PanasonicEasyIPsetupBlueSocketTests: XCTestCase {
    func testDiscovery() throws {
        let manager = try Manager()
		let sem = DispatchSemaphore(value: 0)
		manager.discoveryHandler = { configuration in
			print(configuration)
			sem.signal()
		}
		sem.wait()
    }
	
	func testReconfiguration() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct
		// results.
		let manager = try Manager()
		let sem = DispatchSemaphore(value: 0)
		manager.discoveryHandler = {
			sem.signal()
			do {
				try manager.set(
					configuration: CameraConfiguration(
						macAddress: $0.macAddress,
						ipV4address: [10, 1, 0, 210],
						netmask: [255, 255, 255, 0],
						gateway: [10, 1, 0, 1],
						primaryDNS: [0, 0, 0, 0],
						secondaryDNS: [0, 0, 0, 0],
						port: 80,
						model: "",
						name: ""
					)
				)
			} catch {
				print(error)
			}
		}
		
		sem.wait()
	}


    static var allTests = [
		("Discover camera", testDiscovery),
		("Reconfigure first camera", testReconfiguration),
    ]
}
