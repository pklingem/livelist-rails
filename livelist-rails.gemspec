# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "livelist/rails/version"

Gem::Specification.new do |s|
  s.name        = "livelist-rails"
  s.version     = Livelist::Rails::VERSION
  s.authors     = ["Patrick Klingemann"]
  s.email       = ["patrick.klingemann@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A Rails Engine/Extension Incorporating Livelist.js}
  s.description = %q{livelist-rails is a Rails 3.1 Engine/Extension incorporating the following javascript libraries: Mustache.js, underscore.js, jQuery and livelist.js, and providing ActiveRecord filtering extenstions.}

  s.rubyforge_project = "livelist-rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'activerecord'
end
