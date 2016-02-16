import Foundation

/// Class for logging excessive blocking on the main thread.
@objc final public class Watchdog: NSObject {
    private let threshold: Double
    private let pingThread: PingThread

    private static let defaultThreshold = 0.4
    
    /// @param threshold number of seconds that must pass to consider the main thread blocked.
    /// @param strictMode boolean value that stops the execution whenever the threshold is reached.
    public convenience init(threshold: Double = Watchdog.defaultThreshold, strictMode: Bool = false) {
        self.init(threshold: threshold) {
            let message = "👮 Main thread was blocked for "
                + String(format:"%.2f", threshold) + "s 👮"

            if strictMode {
                assertionFailure()
            } else {
                NSLog("%@", message)
            }
        }
    }

    /// @param threshold number of seconds that must pass to consider the main thread blocked.
    /// @param watchdogFiredCallback a callback that will be called when the the threshold is reached
    public init(threshold: Double = Watchdog.defaultThreshold, watchdogFiredCallback: () -> Void) {
        self.threshold = threshold
        self.pingThread = PingThread(threshold: threshold, handler: watchdogFiredCallback)

        self.pingThread.start()
        super.init()
    }
    
    deinit {
        pingThread.cancel()
    }
}

private final class PingThread: NSThread {
    var pingTaskIsRunning = false
    var semaphore = dispatch_semaphore_create(0)
    let threshold: Double
    let handler: () -> Void
    
    init(threshold: Double, handler: () -> Void) {
        self.threshold = threshold
        self.handler = handler
    }
    
    override func main() {
        while !self.cancelled {
            pingTaskIsRunning = true
            dispatch_async(dispatch_get_main_queue()) {
                self.pingTaskIsRunning = false
                dispatch_semaphore_signal(self.semaphore)
            }
            
            NSThread.sleepForTimeInterval(threshold)
            if pingTaskIsRunning {
                self.handler()
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
    }
}
