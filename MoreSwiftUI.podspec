#
# Be sure to run `pod lib lint MoreSwiftUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MoreSwiftUI'
  s.version          = '0.2.1'
  s.summary          = 'MoreSwiftUI collects small controls and extensions that based on SwiftUI.'
  s.platform = :osx, '13.0'
  s.platform = :ios, '16.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'MoreSwiftUI provides small controls and extensions that based on SwiftUI. It try to reduce the effort to customize SwiftUI components.'

  s.homepage         = 'https://github.com/chenhaiteng/MoreSwiftUI' 
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Chen-Hai Teng'
  s.source           = { :git => 'https://github.com/chenhaiteng/MoreSwiftUI.git', :tag => s.version.to_s }
  s.swift_version    = '5.9'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.osx.deployment_target = '13.0'
  s.ios.deployment_target = '16.0'

  s.source_files = 'Sources/MoreSwiftUI/**/*.swift'
  
  # s.resource_bundles = {
  #   'MoreSwiftUI' => ['MoreSwiftUI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
