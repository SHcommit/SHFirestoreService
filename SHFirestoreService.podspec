#
# Be sure to run `pod lib lint SHFirestoreService.podspec' to ensure this is a
# valid spec before submitting.


Pod::Spec.new do |s|
s.name             = 'SHFirestoreService'
s.version          = '1.0.0'
s.summary          = "A library to easily manage endpoints and requests with combine when using Firebase's Firestore."

s.homepage         = 'https://github.com/SHcommit/SHFirestoreService'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'SHcommit' => 'happysh_s2@naver.com' }
s.source           = { :git => 'https://github.com/SHcommit/SHFirestoreService.git', :tag => s.version.to_s }

s.ios.deployment_target = '13.0'
# s.source_files = 'Sources/SHFirestoreService/**/*.{h,m,swift}'
s.swift_version         = '5.0'

s.frameworks            = "UIKit"


# Cocoapods deployment is not possible because FirebaseCombineSwift is not registered in Cocoapods.
# s.dependency 'FirebaseFirestore'
# s.dependency 'Firebase/FirebaseCombineSwift'
end
