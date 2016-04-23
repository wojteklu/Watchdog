import Foundation

/// Class for logging excessive blocking on the main thread.
@objc final public class Watchdog: NSObject {
    private let pingThread: PingThread

    private static let defaultThreshold = 0.4

    /// Convenience initializer that allows you to construct a `WatchDog` object with default behavior.
    /// - parameter threshold: number of seconds that must pass to consider the main thread blocked.
    /// - parameter strictMode: boolean value that stops the execution whenever the threshold is reached.
    public convenience init(threshold: Double = Watchdog.defaultThreshold, strictMode: Bool = false) {
        let message = "👮 Main thread was blocked for " + String(format:"%.2f", threshold) + "s 👮"

        self.init(threshold: threshold) {
            if strictMode {
                assertionFailure(message)
            } else {
                NSLog("%@", message)
            }
        }
    }

    /// Default initializer that allows you to construct a `WatchDog` object specifying a custom callback.
    /// - parameter threshold: number of seconds that must pass to consider the main thread blocked.
    /// - parameter watchdogFiredCallback: a callback that will be called when the the threshold is reached
    public init(threshold: Double = Watchdog.defaultThreshold, watchdogFiredCallback: () -> Void) {
        self.pingThread = PingThread(threshold: threshold, handler: watchdogFiredCallback)

        self.pingThread.start()
        super.init()
    }
    
    deinit {
        pingThread.cancel()
    }
}

private final class PingThread: NSThread {
    private var pingTaskIsRunning = false
    private var semaphore = dispatch_semaphore_create(0)
    private let threshold: Double
    private let handler: () -> Void
    
    init(threshold: Double, handler: () -> Void) {
        self.threshold = threshold
        self.handler = handler
    }
    
    override func main() {
        while !cancelled {
            pingTaskIsRunning = true
            dispatch_async(dispatch_get_main_queue()) {
                self.pingTaskIsRunning = false
                dispatch_semaphore_signal(self.semaphore)
            }
            
            NSThread.sleepForTimeInterval(threshold)
            if pingTaskIsRunning {
                handler()
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
    }
}
