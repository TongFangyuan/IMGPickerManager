Pod::Spec.new do |s|

  s.name         = "IMGPickerManager"
  s.version      = "0.1.2"
  s.summary      = " Picture video selection framework."
  s.description  = <<-DESC
                    An integrated, simple, independent, efficient, lightweight, and continuously updated image selects a third-party framework.
                   DESC
  s.homepage     = "https://github.com/TongFangyuan/IMGPickerManager"
  s.license      = "MIT"
  s.author             = { "tony" => "tonytongfangyuan@gmail.com" }
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/TongFangyuan/IMGPickerManager.git", :tag => s.version }
  s.source_files = 'IMGPickerManagerDemo/IMGPickerManager/*.{h,m}'
  s.resources = "IMGPickerManagerDemo/IMGPickerManager/Resources/*.png"
  s.framework  = "UIKit"
  s.requires_arc = true
  s.dependency "Masonry"

end
