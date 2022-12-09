source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!
platform :ios, '12.0'
project 'PopMovies.xcodeproj'

def shared_pods_general
    pod 'RxSwift', '5.1.0'
    pod 'RxCocoa', '5.1.0'
    pod 'RxAlamofire', '5.1.0'
    pod 'RxAnimated', '0.6.1'
    pod 'Swinject', '2.7.1'
    pod 'SwinjectAutoregistration', '2.7.0'
    pod 'ReachabilitySwift', '5.0.0'
    pod 'SwiftyJSON', '5.0.0'
    pod 'Kingfisher', '5.13.2'
    pod 'AlamofireNetworkActivityLogger', '2.4.0'
    pod 'RxDataSources', '4.0.1'
    pod 'Device', '3.2.1'
end

target 'PopMovies' do
    shared_pods_general
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete('CODE_SIGNING_ALLOWED')
            config.build_settings.delete('CODE_SIGNING_REQUIRED')
        end
    end
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
