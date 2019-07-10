#
# Be sure to run `pod lib lint HTNetworkKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HTNetworkKit'
  s.version          = '0.1.1'
  s.summary          = '网络请求封装，WebService+HTTP请求.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/icpmobile/HTNetworkKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JamesLiAndroid' => 'lisongyang@hoteamsoft.com' }
  s.source           = { :git => 'https://github.com/icpmobile/HTNetworkKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'HTNetworkKit/Classes/**/*'
  # 关于无法导入HTModelKit文件的问题
  # 第三方库里面.h文件找不到的问题解决
  s.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }
  
  # libxml2找不到的问题修复
  s.libraries = 'z', 'xml2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  
  # ARC项目引入MRC代码的问题修复
  # 需要添加mrc标识的文件
  non_arc_files = 'HTNetworkKit/Classes/webservice/SoapXmlParseHelper.{h,m}', 'HTNetworkKit/Classes/webservice/GDataXMLNode.{h,m}'
  # 在工程中首先排除一下
  s.exclude_files = non_arc_files

  # 子设置，为需要添加mrc标识的文件进行设置
  s.subspec 'no-arc' do |sp|
    sp.source_files = non_arc_files
    sp.requires_arc = false
  end

  # s.resource_bundles = {
  #   'HTNetworkKit' => ['HTNetworkKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  #s.frameworks = 'HTToolKit'
  #s.dependency 'HTToolsKit/FileManager'
  s.dependency 'HTModelKit'
  s.dependency 'HTToolsKit'
  s.dependency 'AFNetworking', '~>3.0'
end
