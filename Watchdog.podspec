Pod::Spec.new do |s|
  s.name             = "Watchdog"
  s.version          = "2.0"
  s.summary          = "Class for logging excessive blocking on the main thread."

  s.description      = <<-DESC
  Class for logging excessive blocking on the main thread. It watches the main thread and checks if it doesn’t get blocked for more than defined threshold. You can also inspect which part of your code is blocking the main thread.
                       DESC

  s.homepage         = "https://github.com/wojteklu/Watchdog"
  s.license          = 'MIT'
  s.author           = { "Wojtek Lukaszuk" => "lukaszuk.wojtek@gmail.com" }
  s.source           = { :git => "https://github.com/wojteklu/Watchdog.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/wojteklu'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = 'Classes/*.swift'

end
