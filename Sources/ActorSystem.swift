import Foundation

public class ActorSystem {
    public let name: String

    private var actors: [String: ActorRef] = [:]

    private let lock = NSRecursiveLock()

    public init(name: String) {
        self.name = name
    }

    @discardableResult
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
