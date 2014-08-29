# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gooddata_connectors_base/version'

Gem::Specification.new do |spec|
  spec.name          = "gooddata_connectors_base"
  spec.version       = GoodDataConnectorsBase::VERSION
  spec.authors       = ["Adrian Toman"]
  spec.email         = ["adrian.toman@gooddata.com"]
  spec.description   = %q{This is base gem, used for defining connectors interface}
  spec.summary       = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~>2.14'
  spec.add_dependency "gooddata"
  spec.add_dependency "aws-sdk"
end
