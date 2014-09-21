Pod::Spec.new do |s|
  s.name             = "async"
  s.version          = "0.1.0"
  s.summary          = "Common interface for asynchronous control flow in #swift."
  s.homepage         = "https://github.com/OliverLetterer/swift-async"
  s.license          = 'MIT'
  s.author           = { "Oliver Letterer" => "oliver.letterer@gmail.com" }
  s.source           = { :git => "https://github.com/OliverLetterer/swift-async.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/oletterer'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'async/*.h'
  # s.source_files = 'async/*.{h,swift}'
  s.frameworks = 'Foundation'
end
