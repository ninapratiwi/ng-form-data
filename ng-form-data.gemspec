# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ng/form/data/package'

Gem::Specification.new do |spec|
  spec.name          = Ng::Form::Data::NAME
  spec.version       = Ng::Form::Data::VERSION
  spec.authors       = [Ng::Form::Data::AUTHOR["name"]]
  spec.email         = [Ng::Form::Data::AUTHOR["email"]]
  spec.summary       = Ng::Form::Data::DESCRIPTION
  spec.description   = Ng::Form::Data::LONGDESCRIPTION
  spec.homepage      = Ng::Form::Data::HOMEPAGE
  spec.license       = Ng::Form::Data::LICENSE["type"]

  spec.files         = ["package.json", "LICENSE", "README.md"] + Dir["lib/**/*.rb"] + Dir["vendor/assets/javascripts/*.js"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  
  spec.add_runtime_dependency "railties", ">= 3.1"
end
