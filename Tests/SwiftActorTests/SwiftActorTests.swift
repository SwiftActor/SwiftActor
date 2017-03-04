import XCTest
@testable import SwiftActor

class SwiftActorTests: XCTestCase {
    func testExample() {
        let expectation = self.expectation(description: "")

        struct StopMessage {}

        class FooBar: Actor {
            open override func preStart() {
                context.actorOf(Baz.self, name: "baz")
            }

            open override func receive(_ message: Any) {
                print("parent \(message)")
                context.actorOf(Baz.self, name: "baz").tell(message)

                if message is StopMessage {
                    context.stop(actor: selfRef)
                }
            }

            open override func postStop() {
                let baz = context.actorOf(Baz.self, name: "baz")
                context.stop(actor: baz)
            }
        }

        class Baz: Actor {
            var expectation: XCTestExpectation?

            open override func receive(_ message: Any) {
                print("child")
            }

            open override func postStop() {
                expectation?.fulfill()
            }
        }

        let system = ActorSystem(name: "test")
        let ref = system.actorOf(FooBar.self, name: "foobar")

        (system.actorOf(Baz.self, name: "baz").actor as! Baz).expectation = expectation
        for i in 0..<10000 {
            ref.tell("hogehoge \(i)")
        }
        ref.tell(StopMessage())

        waitForExpectations(timeout: 10) { _ in }
    }


    static var allTests : [(String, (SwiftActorTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
