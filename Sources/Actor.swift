import Foundation
import Dispatch

open class Actor: ActorProtocol {
    public let context: ActorContext
    public let queue: DispatchQueue

    public internal(set) var selfRef: ActorRef!

    private var mailbox: [Any] = []

    private var timer: DispatchSourceTimer?

    public required init(context: ActorContext) {
        self.context = context
        self.queue = type(of: self).queue

        preStart()
        start()
    }

    class var queue: DispatchQueue {
        return DispatchQueue(label: String(describing: type(of: self)))
    }

    public func preStart() {
        // no-op
    }

    open func postStop() {
        // no-op
    }

    public func tell(_ message: Any) {
        queue.async {
            self.mailbox.append(message)
        }
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
