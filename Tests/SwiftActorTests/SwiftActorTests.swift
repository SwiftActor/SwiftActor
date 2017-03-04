import XCTest
@testable import SwiftActor

class SwiftActorTests: XCTestCase {
    func testExample() {
        let expectation = self.expectation(description: "")

        class FooBar: Actor {
            open override func preStart() {
                actorRefProvider.actorOf(Baz.self, name: "baz")
            }

            open override func receive(_ message: Any) {
                print("parent \(message)")
                actorRefProvider.actorFor(name: "baz")?.tell(message)
            }

            open override func postStop() {
                if let baz = actorRefProvider.actorFor(name: "baz") {
                    actorRefProvider.stop(actor: baz)
                }
            }
        }

        class Baz: Actor {
            var expectation: XCTestExpectation?

            open override func receive(_ message: Any) {
                print("child")
                expectation?.fulfill()
            }
        }

        let system = ActorSystem(name: "test")
        let ref = system.actorOf(FooBar.self, name: "foobar")

        (system.actorFor(name: "baz")?.actor as! Baz).expectation = expectation
        ref.tell("hogehoge")

        waitForExpectations(timeout: 1) { _ in }
    }


    static var allTests : [(String, (SwiftActorTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
