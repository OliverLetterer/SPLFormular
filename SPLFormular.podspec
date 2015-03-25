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
  s.version          = "0.1.0"
  s.summary          = "A short description of SPLFormular."
  s.homepage         = "https://github.com/OliverLetterer/SPLFormular"
  s.license          = 'MIT'
  s.author           = { "Oliver Letterer" => "oliver.letterer@gmail.com" }
  s.source           = { :git => "https://github.com/OliverLetterer/SPLFormular.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/oletterer'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'SPLFormular'
  # s.resource_bundles = {
  #   'SPLFormular' => [ 'SPLFormular/Resources/*' ]
  # }

  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
