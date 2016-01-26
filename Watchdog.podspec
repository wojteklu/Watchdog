Pod::Spec.new do |s|
  s.name             = "Watchdog"
  s.version          = "1.1"
  s.summary          = "Class for logging excessive blocking on the main thread."

  s.description      = <<-DESC
  Class for logging excessive blocking on the main thread. It observes the run loop and detect any stalling or blocking that occurs.
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
