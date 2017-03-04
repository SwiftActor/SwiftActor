import XCTest
@testable import SwiftActor

class SwiftActorTests: XCTestCase {
    func testExample() {
        let expectation = self.expectation(description: "")

        class FooBar: Actor {
            var expectation: XCTestExpectation?

            required init(actorRefProvider: ActorRefProvider) {
                super.init(actorRefProvider: actorRefProvider)
                actorRefProvider.actorOf(Baz.self, name: "baz")
            }

            open override func receive(_ message: Any) {
                print("parent \(message)")
                actorRefProvider.actorFor(name: "baz")?.tell(message)
                expectation?.fulfill()
            }
        }

        class Baz: Actor {
            open override func receive(_ message: Any) {
                print("child")
            }
        }

        let system = ActorSystem(name: "test")
        let ref = system.actorOf(FooBar.self, name: "foobar")

        (ref.actor as! FooBar).expectation = expectation
        ref.tell("hogehoge")

        waitForExpectations(timeout: 1) { _ in }
    }


    static var allTests : [(String, (SwiftActorTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
