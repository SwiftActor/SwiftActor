import Foundation
import Dispatch

public protocol ActorProtocol: class {
    var queue: DispatchQueue { get }

    func preStart()
    func postStop()

    func tell(_ message: Any)
    func receive(_ message: Any)
}

open class Actor: ActorProtocol {
    public let context: ActorContext
    public let queue: DispatchQueue

    public fileprivate(set) var selfRef: ActorRef!

    var mailbox: [Any] = []

    var timer: DispatchSourceTimer?

    public required init(context: ActorContext) {
        self.context = context
        self.queue = type(of: self).queue

        preStart()
        start()
    }

    class var queue: DispatchQueue {
        return DispatchQueue(label: "")
    }

    public func preStart() {
        // no-op
    }

    open func postStop() {
        // no-op
    }

    open func receive(_ message: Any) {
        // no-op
    }

    internal func start() {
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.scheduleRepeating(deadline: .now(), interval: .microseconds(1))
        timer?.setEventHandler { [unowned self] in
            if !self.mailbox.isEmpty {
                let message = self.mailbox.removeFirst()
                self.receive(message)
            }
        }
        timer?.resume()
    }

    internal func stop() {
        timer?.cancel()
        timer = nil
    }
}

public class MainThreadActor: Actor {
    override class var queue: DispatchQueue {
        return DispatchQueue.main
    }
}

extension Actor {
    public func tell(_ message: Any) {
        queue.async {
            self.mailbox.append(message)
        }
    }
}

public class ActorRef {
    let actor: Actor
    let name: String

    public init(actor: Actor, name: String) {
        self.actor = actor
        self.name = name

        actor.selfRef = self
    }

    public func tell(_ message: Any) {
        actor.tell(message)
    }
}

public protocol ActorContext {
    var system: ActorSystem { get }

    @discardableResult
    func actorOf(_ type: Actor.Type, name: String) -> ActorRef
    func actorFor(name: String) -> ActorRef?

    func stop(actor: ActorRef)
}

internal final class ActorContextImpl: ActorContext {
    let system: ActorSystem

    init(system: ActorSystem) {
        self.system = system
    }

    @discardableResult
    func actorOf(_ type: Actor.Type, name: String) -> ActorRef {
        return system.actorOf(type, name: name)
    }

    func actorFor(name: String) -> ActorRef? {
        return system.actorFor(name: name)
    }

    func stop(actor: ActorRef) {
        system.stop(actor: actor)
    }
}

public class ActorSystem {
    let name: String

    var actors: [String: ActorRef] = [:]

    let lock = NSRecursiveLock()

    public init(name: String) {
        self.name = name
    }

    public func actorOf(_ type: Actor.Type, name: String) -> ActorRef {
        lock.lock()
        defer { lock.unlock() }

        if let ref = actors[name] {
            return ref
        } else {
            let context = ActorContextImpl(system: self)
            let actor = type.init(context: context)
            let ref = ActorRef(actor: actor, name: name)
            actors[name] = ref
            return ref
        }
    }

    public func actorFor(name: String) -> ActorRef? {
        lock.lock()
        defer { lock.unlock() }
        return actors[name]
    }

    public func stop(actor: ActorRef) {
        actor.actor.stop()
        actor.actor.postStop()
        lock.lock()
        actors.removeValue(forKey: actor.name)
        lock.unlock()
    }
}
