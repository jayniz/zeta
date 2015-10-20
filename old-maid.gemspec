# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'old-maid/version'

Gem::Specification.new do |spec|
  spec.name          = 'old-maid'
  spec.version       = OldMaid::VERSION
  spec.authors       = ['Jannis Hermanns']
  spec.email         = ['jannis@gmail.com']

  spec.summary       = 'Collects and validates the publish/consume contracts of your infrastructure'
  spec.description   = 'Vlad'
  spec.homepage      = 'https://github.com/moviepilot/old-maid'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rake', '~> 10.2'
  spec.add_runtime_dependency 'minimum-term', '~> 0.2'
  spec.add_runtime_dependency 'activesupport', '~> 4.2'
  spec.add_runtime_dependency 'httparty', '~> 0.13'
  spec.add_runtime_dependency 'colorize'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'webmock'
end
