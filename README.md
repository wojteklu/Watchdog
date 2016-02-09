# Watchdog
Class for logging excessive blocking on the main thread. It watches the main thread and checks if it doesn’t get blocked for more than defined threshold. You can also inspect which part of your code is blocking the main thread.

```
👮 Main thread was blocked for 1.25s 👮
```
## Requirements

* iOS 8.0+, tvOS 9.0+ or OS X 10.9+
* Xcode 7.0 or above

## Installation

### [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

Add the following to your Cartfile:

```
github "wojteklu/Watchdog"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### [CocoaPods]

[CocoaPods]: http://cocoapods.org

Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
pod 'Watchdog'
```

You will also need to make sure you're opting into using frameworks:

```ruby
use_frameworks!
```

Then run `pod install` with CocoaPods 0.36 or newer.

### Manually

Manually add the file into your Xcode project. Slightly simpler, but updates are also manual.

## Usage

Simply, just instantiate Watchdog with number of seconds that must pass to consider the main thread blocked. Additionally you can enable `strictMode` that stops the execution whenever the threshold is reached. This way, you can inspect which part of your code is blocking the main thread.

```Swift
let watchdog = Watchdog(threshold: 0.4, strictMode: true)
```

Don't forget to retain Watchdog somewhere or it will get released when it goes out of scope.

## Author

Wojtek Lukaszuk [@wojteklu](http://twitter.com/wojteklu)

## License

Watchdog is available under the MIT license. See the LICENSE file for more info.
