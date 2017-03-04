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
