#
# Be sure to run `pod lib lint SPLFormular.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SPLFormular"
  s.version          = "0.8.0"
  s.summary          = "Simply dynamic formulars, backed by SPLTableViewBehavior."
  s.homepage         = "https://github.com/OliverLetterer/SPLFormular"
  s.license          = 'MIT'
  s.author           = { "Oliver Letterer" => "oliver.letterer@gmail.com" }
  s.source           = { :git => "https://github.com/OliverLetterer/SPLFormular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/oletterer'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'SPLFormular', 'SPLFormular/Private'
  s.private_header_files = 'SPLFormular/Private/*.h'
  s.prefix_header_contents = '#ifndef NS_BLOCK_ASSERTIONS', '#define __assert_unused', '#else', '#define __assert_unused __unused', '#endif'

  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SPLTableViewBehavior', '~> 0.8.3'
end
