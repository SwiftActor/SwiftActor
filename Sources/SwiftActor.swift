import Dispatch

public protocol ActorProtocol: class {
    var queue: DispatchQueue { get }

    func tell(_ message: Any)
    func receive(_ message: Any)
}

open class Actor: ActorProtocol {
    public let actorRefProvider: ActorRefProvider
    public let queue: DispatchQueue
    var mailbox: [Any] = []

    public required init(actorRefProvider: ActorRefProvider) {
        self.actorRefProvider = actorRefProvider
        self.queue = type(of: self).queue
    }

    class var queue: DispatchQueue {
        return DispatchQueue(label: "")
    }

    open func receive(_ message: Any) {
        // no-op
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
            self.receive(message)
//            self.mailbox.append(message)
        }
    }
}

public class ActorRef {
    let actor: Actor

    public init(actor: Actor) {
        self.actor = actor
    }

    public func tell(_ message: Any) {
        actor.tell(message)
    }
}

public protocol ActorRefProvider {
    @discardableResult
    func actorOf(_ type: Actor.Type, name: String) -> ActorRef
    func actorFor(name: String) -> ActorRef?
}

public class ActorSystem: ActorRefProvider {
    let name: String

    var actors: [String: ActorRef] = [:]

    public init(name: String) {
        self.name = name
    }

    public func actorOf(_ type: Actor.Type, name: String) -> ActorRef {
        let actor = type.init(actorRefProvider: self)
        let ref = ActorRef(actor: actor)
        actors[name] = ref
        return ref
    }

    public func actorFor(name: String) -> ActorRef? {
        return actors[name]
    }
}
