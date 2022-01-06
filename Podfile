# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'KNU_Market' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KNU_Market
  pod 'Alamofire', '~> 5.2'
  pod 'IQKeyboardManagerSwift'
  pod "BSImagePicker", "~> 3.1"
  
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/DynamicLinks'
  

  pod "GMStepper"
  pod "MessageKit"
  pod 'InputBarAccessoryView'
  pod 'MessageInputBar'

  
  pod 'ProgressHUD'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'SwiftKeychainWrapper'
  pod 'SPIndicator'
  pod 'SnackBar.swift'
  pod 'ViewAnimator'
  pod 'SDWebImage', '~> 5.0'
  pod 'ImageSlideshow', '~> 1.9.0'
  pod "ImageSlideshow/SDWebImage"
  pod 'HGPlaceholders'
  pod 'PanModal'
  pod 'TextFieldEffects'
  pod 'PMAlertController'
  

  # UI
  pod 'lottie-ios'
  pod 'UITextView+Placeholder'
  pod 'Hero'
  pod 'MHLoadingButton'
  pod 'Atributika'
  
  # Architecture
  pod 'ReactorKit'

  # Rx
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxViewController'
  pod 'RxAnimated'
  pod 'RxGesture'
  pod 'RxKeyboard'
  pod 'RxDataSources'
  pod 'ReusableKit'

  # Network
  pod 'Starscream', '~> 4.0.0'
  pod 'Moya/RxSwift'

  # ETC
  pod 'Then'

post_install do |installer|   
      installer.pods_project.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      end
end

end
