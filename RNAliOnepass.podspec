
Pod::Spec.new do |s|
  s.name         = "RNAliOnepass"
  s.version      = "1.0.0"
  s.summary      = "RNAliOnepass"
  s.description  = "RNAliOnepass"
  s.homepage     = "https://github.com/EatherToo/react-native-onepass-alibaba"
  s.license      = "MIT"
  s.author             = { "Eather" => "eathertoo@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/EatherToo/react-native-onepass-alibaba.git", :tag => "master" }
  s.source_files  = "ios/*.{h,m}"
  s.resources =  'ios/libs/ATAuthSDK.framework/ATAuthSDK.bundle'
  s.vendored_frameworks = 'ios/libs/ATAuthSDK.framework'
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
