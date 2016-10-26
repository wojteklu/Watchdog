import Foundation

/// Check app is debugging now
///
/// - returns: true/false
func isAppDebugging() -> Bool {
    let once: Bool = {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout.stride(ofValue: info)
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        Swift.assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }()
    return once
}

/// Class for logging excessive blocking on the main thread.
@objc final public class Watchdog: NSObject {
    fileprivate let pingThread: PingThread

    fileprivate static let defaultThreshold = 0.4

    /// Convenience initializer that allows you to construct a `WatchDog` object with default behavior.
    /// - parameter threshold: number of seconds that must pass to consider the main thread blocked.
    /// - parameter strictMode: boolean value that stops the execution whenever the threshold is reached.
    public convenience init(threshold: Double = Watchdog.defaultThreshold, strictMode: Bool = false) {
        let message = "👮 Main thread was blocked for " + String(format:"%.2f", threshold) + "s 👮"

        self.init(threshold: threshold) {
            if strictMode && !isAppDebugging() {
                assertionFailure(message)
            } else {
                NSLog("%@", message)
            }
        }
    }

    /// Default initializer that allows you to construct a `WatchDog` object specifying a custom callback.
    /// - parameter threshold: number of seconds that must pass to consider the main thread blocked.
    /// - parameter watchdogFiredCallback: a callback that will be called when the the threshold is reached
    public init(threshold: Double = Watchdog.defaultThreshold, watchdogFiredCallback: @escaping () -> Void) {
        self.pingThread = PingThread(threshold: threshold, handler: watchdogFiredCallback)

        self.pingThread.start()
        super.init()
    }
    
    deinit {
        pingThread.cancel()
    }
}

private final class PingThread: Thread {
    fileprivate var pingTaskIsRunning = false
    fileprivate var semaphore = DispatchSemaphore(value: 0)
    fileprivate let threshold: Double
    fileprivate let handler: () -> Void
    
    init(threshold: Double, handler: @escaping () -> Void) {
        self.threshold = threshold
        self.handler = handler
    }
    
    override func main() {
        while !isCancelled {
            pingTaskIsRunning = true
            DispatchQueue.main.async {
                self.pingTaskIsRunning = false
                self.semaphore.signal()
            }
            
            Thread.sleep(forTimeInterval: threshold)
            if pingTaskIsRunning {
                handler()
            }
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
}
