# -*- encoding: utf-8 -*-
require 'rake'

$:.push File.expand_path('../lib', __FILE__)
require 'composer/semver'

Gem::Specification.new do |spec|
  spec.name             = 'php-composer-semver'
  spec.version          = ::Composer::Semver::GEM_VERSION
  spec.authors          = ['Ioannis Kappas']
  spec.email            = ['ikappas@devworks.gr']

  spec.summary          = %q{PHP Composer Semver Ruby Gem}
  spec.description      = %q{A ruby gem library for that offers utilities, version constraint parsing and validation.}
  spec.homepage         = %q{http://github.com/ikappas/php-composer-semver/tree/master}
  spec.license          = 'MIT'

  spec.files            = FileList['lib/**/*.rb', 'LICENSE.txt', 'README.md']
  spec.test_files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths    = ['lib']

  spec.required_ruby_version = '>= 1.8.7'
  spec.required_rubygems_version = '>= 1.8'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 5.0'
  spec.add_development_dependency 'rubocop', '~> 0.35', '>= 0.35.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.3', '>= 1.3.1'
  spec.add_development_dependency 'simplecov', '~> 0.10'
end
