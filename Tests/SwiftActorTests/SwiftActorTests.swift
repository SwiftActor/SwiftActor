import XCTest
@testable import SwiftActor

class SwiftActorTests: XCTestCase {
    func testExample() {
        let expectation = self.expectation(description: "")

        struct StopMessage {}

        class Foo: Actor {
            open override func preStart() {
                context.actorOf(Baz.self, name: "baz")
            }

            open override func receive(_ message: Any) {
                print("Foo \(message)")
                context.actorFor(name: "baz")?.tell(message)

                if message is StopMessage {
                    context.stop(actor: selfRef)
                }
            }

            open override func postStop() {
                if let baz = context.actorFor(name: "baz") {
                    context.stop(actor: baz)
                }
            }
        }

        class Bar: Actor {
            open override func preStart() {
                context.actorOf(Baz.self, name: "baz")
            }

            open override func receive(_ message: Any) {
                print("Bar \(message)")
                context.actorOf(Baz.self, name: "baz").tell(message)

                if message is StopMessage {
                    context.stop(actor: selfRef)
                }
            }

            open override func postStop() {
                if let baz = context.actorFor(name: "baz") {
                    context.stop(actor: baz)
                }
            }
        }

        class Baz: Actor {
            var expectation: XCTestExpectation?

            required init(context: ActorContext) {
                super.init(context: context)
            }

            open override func receive(_ message: Any) {
                print("child \(message)")
            }

            open override func postStop() {
                print("child stopped: \(self)")
                expectation?.fulfill()
            }
        }

        let system = ActorSystem(name: "test")
        let foo = system.actorOf(Foo.self, name: "foo")
        let bar = system.actorOf(Foo.self, name: "bar")
        system.actorOf(Baz.self, name: "baz")

        (system.actorOf(Baz.self, name: "baz").actor as! Baz).expectation = expectation
        for i in 0..<10000 {
            foo.tell("hogehoge \(i)")
            bar.tell("fugafuga \(i)")

        }
        foo.tell(StopMessage())
        bar.tell(StopMessage())

        waitForExpectations(timeout: 20) { _ in }
    }


    static var allTests : [(String, (SwiftActorTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
