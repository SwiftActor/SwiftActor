import Dispatch

public protocol ActorProtocol: class {
    var queue: DispatchQueue { get }

    func preStart()
    func postStop()

    func tell(_ message: Any)
    func receive(_ message: Any)
}
