Pod::Spec.new do |s|

  s.name = 'Atsani'
  s.version = '1.0.0'
  
  s.summary = ''
  s.description = <<-DESC 
                  
                  DESC

  s.homepage = 'https://github.com/spirit-jsb/Atsani.git'

  s.authors = {'spirit-jsb' => 'sibo_jian_29903549@163.com'}
  
  s.license = 'MIT'
  
  s.swift_version = '5.0'

  s.ios.deployment_target = '13.0'
  
  s.source = { :git => 'https://github.com/spirit-jsb/Atsani.git', :tag => s.version}
  s.source_files = ["Sources/**/*.swift"]
  
  s.requires_arc = true

end