import Dispatch

public protocol ActorProtocol: class {
    var queue: DispatchQueue { get }

    func preStart()
    func postStop()

    func tell(_ message: Any)
    func receive(_ message: Any)
}

open class Actor: ActorProtocol {
    public let actorRefProvider: ActorRefProvider
    public let queue: DispatchQueue
    var mailbox: [Any] = []

    var timer: DispatchSourceTimer?

    public required init(actorRefProvider: ActorRefProvider) {
        self.actorRefProvider = actorRefProvider
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
        timer?.scheduleRepeating(deadline: .now(), interval: .milliseconds(100))
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
    }

    public func tell(_ message: Any) {
        actor.tell(message)
    }
}

public protocol ActorRefProvider {
    @discardableResult
    func actorOf(_ type: Actor.Type, name: String) -> ActorRef
    func actorFor(name: String) -> ActorRef?
    func stop(actor: ActorRef)
}

public class ActorSystem: ActorRefProvider {
    let name: String

    var actors: [String: ActorRef] = [:]

    public init(name: String) {
        self.name = name
    }

    public func actorOf(_ type: Actor.Type, name: String) -> ActorRef {
        let actor = type.init(actorRefProvider: self)
        let ref = ActorRef(actor: actor, name: name)
        actors[name] = ref
        return ref
    }

    public func actorFor(name: String) -> ActorRef? {
        return actors[name]
    }

    public func stop(actor: ActorRef) {
        actor.actor.stop()
        actor.actor.postStop()
        actors.removeValue(forKey: actor.name)
    }
}
