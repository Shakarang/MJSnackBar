# @Author: Maxime JUNGER <junger_m>
# @Date:   02-04-2016
# @Email:  maximejunger@gmail.com
# @Last modified by:   junger_m
# @Last modified time: 02-04-2016



#
# Be sure to run `pod lib lint MJSnackBar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MJSnackBar"
  s.version          = "1.0.2"
  s.summary          = "iOS implementation of the Android SnackBar used in some Google Apps"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
  MJSnackBar in an iOS implementation of the Android SnackBar used in some Google Apps. It's written in pure Swift.
                       DESC

  s.homepage         = "https://github.com/Shakarang/MJSnackBar"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Maxime Junger" => "maxime.junger@epitech.eu" }
  s.source           = { :git => "https://github.com/Shakarang/MJSnackBar.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Source/*'
  # s.resource_bundles = {
  #   'MJSnackBar' => ['Resources/*.png']
  # }

end
