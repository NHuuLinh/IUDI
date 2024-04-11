# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'IUDI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for IUDI
  pod 'Alamofire', '5.8.0'
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'KeychainSwift'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'CardSlider'
  pod 'CollectionViewPagingLayout'
  pod 'iOSDropDown'
  pod 'Kingfisher'
  pod 'ReadMoreTextView'
  pod 'SwiftRangeSlider'
  pod 'Socket.IO-Client-Swift', '~> 16.1.0'
  pod 'MessageKit'
  pod 'DropDown'


  target 'IUDITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'IUDIUITests' do
    # Pods for testing
  end

end
post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
