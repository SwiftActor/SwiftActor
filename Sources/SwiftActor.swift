import Dispatch

public protocol ActorProtocol: class {
    var queue: DispatchQueue { get }

    func tell(_ message: Any)
    func receive(_ message: Any)
    func unhandled(_ message: Any)
}

open class Actor: ActorProtocol {
    public let queue: DispatchQueue
    var mailbox: [Any] = []

    var timer: DispatchSourceTimer?

    public required init() {
        self.queue = type(of: self).queue
    }

    class var queue: DispatchQueue {
        return DispatchQueue(label: "")
    }

    open func receive(_ message: Any) {
        // no-op
    }

    open func unhandled(_ message: Any) {
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

    public func start() {
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.scheduleRepeating(deadline: .now(), interval: .milliseconds(100))
        timer?.setEventHandler { [weak self] in
            if false {
                self?.stop()
            }
        }
        timer?.resume()
    }

    public func stop() {
        timer?.cancel()
        timer = nil
    }
}

public class ActorRef<T: Actor> {
    let actor: T

    public init(actor: T) {
        self.actor = actor
    }

    public func tell(_ message: Any) {
        actor.tell(message)
    }
}

public class ActorSystem {
    var name: String

    public init(name: String) {
        self.name = name
    }

    public func actorOf<T: Actor>(_ type: T.Type) -> ActorRef<T> {
        let actor = type.init()
        return ActorRef(actor: actor)
    }
}

