import Foundation

/// Class for logging excessive blocking on the main thread.
@objc final public class Watchdog: NSObject {
    private let pingThread: PingThread
    
    private static let defaultThreshold = 0.015
    
    /// Convenience initializer that allows you to construct a `WatchDog` object with default behavior.
    /// - parameter threshold: number of seconds that must pass to consider the main thread blocked.
    /// - parameter strictMode: boolean value that stops the execution whenever the threshold is reached.
    public convenience init(threshold: Double = Watchdog.defaultThreshold, strictMode: Bool = false) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        let callbackWithMessage : (message: String) -> Void = { (message: String) -> Void in
            if strictMode {
                assertionFailure(message)
            } else {
                let timestamp = NSDate()
                let clocktime = clock()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    print("\(dateFormatter.stringFromDate(timestamp)) [\(clocktime)]: \(message)")
                })
            }
        }
        
        self.init(threshold: threshold, notRespondingCallback: { () -> Void in
            callbackWithMessage(message: "👮 Main thread was not responding 👮")
            }, delayInfoCallback: { (delay: Double) -> Void in
                callbackWithMessage(message: "👮 Main thread was blocked for " + String(format:"%.3f", delay) + "s 👮")
        })
        
    }
    
    /// Default initializer that allows you to construct a `WatchDog` object specifying a custom callback.
    /// - parameter threshold: number of seconds that must pass to consider the main thread blocked.
    /// - parameter watchdogFiredCallback: a callback that will be called when the the threshold is reached
    public init(threshold: Double = Watchdog.defaultThreshold, notRespondingCallback: () -> Void, delayInfoCallback: (delay: Double) -> Void) {
        self.pingThread = PingThread(threshold: threshold, notRespondingCallback: notRespondingCallback, delayInfoCallback: delayInfoCallback)
        
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
    private let notRespondingCallback: () -> Void
    private let delayInfoCallback: (delay: Double) -> Void
    
    init(threshold: Double, notRespondingCallback: () -> Void, delayInfoCallback: (delay: Double) -> Void) {
        self.threshold = threshold
        self.notRespondingCallback = notRespondingCallback
        self.delayInfoCallback = delayInfoCallback
    }
    
    override func main() {
        while !cancelled {
            pingTaskIsRunning = true
            let t1 = clock()
            dispatch_async(dispatch_get_main_queue()) {
                self.pingTaskIsRunning = false
                dispatch_semaphore_signal(self.semaphore)
            }
            
            NSThread.sleepForTimeInterval(threshold)
            if pingTaskIsRunning {
                notRespondingCallback()
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            let t2 = clock()
            let dt : Double = Double(t2-t1)/Double(CLOCKS_PER_SEC)
            if dt > threshold {
                delayInfoCallback(delay: dt)
            }
        }
    }
}