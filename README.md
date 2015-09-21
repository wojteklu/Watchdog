# Watchdog
Class for logging excessive blocking on the main thread. It observes the run loop and detect any stalling or blocking that occurs.

```
👮 Main thread was blocked for 1.25s 👮
```

## Requirements

- Swift 2.0

## Installation

### CocoaPods

Watchdog is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod "Watchdog"
```

### Manually

Manually add the file into your Xcode project. Slightly simpler, but updates are also manual.

### Carthage

1. Add `github "wojteklukaszuk/Watchdog" ~> 1.0.2` to your Cartfile or Cartfile.private
2. Run `carthage update`

## Usage

Simply, just instantiate Watchdog with number of seconds that must pass to consider the main thread blocked.

```Swift
let watchdog = Watchdog(threshold: 0.2)
```

You can also write a closure to be called whenever the main thread is blocked

```Swift
let watchdog = Watchdog(threshold: 0.3) { duration in
	print("👮 Main thread was blocked for " + String(format:"%.2f", duration) + "s 👮")
}
```
Don't forget to retain Watchdog somewhere or it will get released when it goes out of scope.

## Author

Wojtek Lukaszuk [@wojteklukaszuk](http://twitter.com/wojteklukaszuk)

Thanks [@jspahrsummers](https://twitter.com/jspahrsummers) for coming up with the original idea.

## License

Watchdog is available under the MIT license. See the LICENSE file for more info.
