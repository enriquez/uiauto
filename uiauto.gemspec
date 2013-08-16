# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uiauto/version'

Gem::Specification.new do |spec|
  spec.name          = "uiauto"
  spec.version       = UIAuto::VERSION
  spec.authors       = ["Mike Enriquez"]
  spec.email         = ["mike@enriquez.me"]
  spec.description   = %q{UI Automation script runner.}
  spec.summary       = %q{UI Automation script runner. Provides a user friendly command line tool for executing automation scripts. Facilitates simulator data setup for executing scripts in repeatable and known states.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "CFPropertyList"
  spec.add_dependency "thor"
end
