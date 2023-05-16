# Uncomment the next line to define a global platform for your project
platform :ios, '14.1'

target 'Biologer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Biologer

  pod 'MaterialComponents/TextControls+OutlinedTextFields'
  pod 'MaterialComponents/TextControls+OutlinedTextAreas'
  pod 'SwiftKeychainWrapper'
  pod 'SideMenu'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'RealmSwift'
  pod 'ReachabilitySwift'
  pod 'lottie-ios'
  
  target 'BiologerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BiologerUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.1'
      end
    end
  end
end
