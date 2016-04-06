require 'rake'

Gem::Specification.new do |s|
  s.name          = 'jenkins-factory'
  s.license       = 'MIT'
  s.version       = '0.0.0'
  s.bindir        = 'bin'
  s.executables   = %w(jenkins_factory)
  s.authors       = %w(someguy)
  s.summary       = 'jenkins_factory'
  s.description   = 'Experimental single-click for cranking out a basic Jenkins instance in EC2'
  s.homepage      = 'https://github.com/stelligent/jenkins-factory'
  s.files         = FileList[ 'lib/**/*.rb', 'lib/**/*.erb' ]

  s.require_paths << 'lib'
  s.require_paths << 'lib/cfndsl'
  s.require_paths << 'lib/xml'

  s.required_ruby_version = '~> 2.2'

  s.add_runtime_dependency('trollop', '2.1.2')
  s.add_runtime_dependency('aws-sdk-utils', '0.0.5')
  s.add_runtime_dependency('jenkins_api_client', '1.4.2')
end