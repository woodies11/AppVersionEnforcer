#
# Be sure to run `pod lib lint AppVersionEnforcer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppVersionEnforcer'
  s.version          = '0.1.6'
  s.summary          = 'Communicate with server and prompt or force the user to update'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Fetch version release data from the server and present to the user an alert and a prompt to update, depending on parameters receive from the server'

  s.homepage         = 'https://github.com/woodies11/AppVersionEnforcer'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Romson Preechawit' => 'r.preechawit@hotmail.com' }
  s.source           = { :git => 'https://github.com/woodies11/AppVersionEnforcer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/woodies11'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AppVersionEnforcer/Classes/**/*'

  # s.resource_bundles = {
  #   'AppVersionEnforcer' => ['AppVersionEnforcer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire', '~> 3.4'
end
