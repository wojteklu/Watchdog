import Foundation

@objc public class Watchdog: NSObject {
    
    /*
    The number of seconds that must pass to consider the main thread blocked
    */
    private var threshold: Double
    
    private var runLoop: CFRunLoopRef = CFRunLoopGetMain()
    private var observer: CFRunLoopObserverRef!
    private var startTime: UInt64 = 0
    private var handler: ((Double) -> ())? = nil
    
    public init(threshold: Double = 0.2, handler: ((Double) -> ())? = nil) {
        
        self.threshold = threshold
        self.handler = handler
        super.init()
        
        var timebase: mach_timebase_info_data_t = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&timebase)
        let secondsPerMachine: NSTimeInterval = NSTimeInterval(Double(timebase.numer) / Double(timebase.denom) / Double(1e9))
        
        observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
            CFRunLoopActivity.AllActivities.rawValue,
            true,
            0) { [weak self] (observer, activity) in
                
                guard let weakSelf = self else {
                    return
                }
                
                switch(activity) {

                case CFRunLoopActivity.Entry, CFRunLoopActivity.BeforeTimers,
                CFRunLoopActivity.AfterWaiting, CFRunLoopActivity.BeforeSources:
                    
                    if weakSelf.startTime == 0 {
                        weakSelf.startTime = mach_absolute_time()
                    }
                    
                case CFRunLoopActivity.BeforeWaiting, CFRunLoopActivity.Exit:
                    
                    let elapsed = mach_absolute_time() - weakSelf.startTime
                    let duration: NSTimeInterval = NSTimeInterval(elapsed) * secondsPerMachine
                    
                    if duration > weakSelf.threshold {
                        if let handler = weakSelf.handler {
                            handler(duration)
                        } else {
                            print("👮 Main thread was blocked for " + String(format:"%.2f", duration) + "s 👮")
                        }
                    }
                    
                    weakSelf.startTime = 0
                    
                default: ()
                }
        }
        
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer!, kCFRunLoopCommonModes)
    }
    
    deinit {
        CFRunLoopObserverInvalidate(observer!)
    }
}