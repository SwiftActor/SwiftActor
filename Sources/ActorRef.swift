public class ActorRef {
    public let actor: Actor
    public let name: String

    public init(actor: Actor, name: String) {
        self.actor = actor
        self.name = name

        actor.selfRef = self
    }

    public func tell(_ message: Any) {
        actor.tell(message)
    }
}
