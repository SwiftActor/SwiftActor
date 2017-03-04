import XCTest
@testable import SwiftActor

class SwiftActorTests: XCTestCase {
    func testExample() {
        let expectation = self.expectation(description: "")

        class FooBar: Actor {
            var expectation: XCTestExpectation?

            open override func receive(_ message: Any) {
                print("received \(message)")
                expectation?.fulfill()
            }
        }

        let system = ActorSystem(name: "test")
        let ref = system.actorOf(FooBar.self)

        ref.actor.expectation = expectation
        ref.tell("hogehoge")

        waitForExpectations(timeout: 1) { _ in }
    }


    static var allTests : [(String, (SwiftActorTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
