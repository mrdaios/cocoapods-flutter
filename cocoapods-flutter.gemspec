# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-flutter/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-flutter'
  spec.version       = CocoapodsFlutter::VERSION
  spec.authors       = ['mrdaios']
  spec.email         = ['mrdaios@gmail.com']
  spec.description   = %q{A short description of cocoapods-flutter.}
  spec.summary       = %q{A longer description of cocoapods-flutter.}
  spec.homepage      = 'https://github.com/EXAMPLE/cocoapods-flutter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
