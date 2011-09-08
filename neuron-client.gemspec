# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "neuron-client/version"

Gem::Specification.new do |s|
  s.name        = "neuron-client"
  s.version     = Neuron::Client::VERSION
  s.authors     = ["RMM Online"]
  s.email       = ["devteam@rmmonline.com"]
  s.homepage    = "http://github.com/rmm/neuron-client"
  s.summary     = "Neuron Admin Client Gem"
  s.description = s.summary

  s.rubyforge_project = "neuron-client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "rest-client", "~> 1.6.3"
  s.add_dependency "yajl-ruby", "~> 0.8.2"
  s.add_dependency "activesupport", ">= 2.3.11", "< 3.2"
  s.add_dependency "tzinfo", "~> 0.3.29"
  s.add_dependency "i18n", "~> 0.6.0"
  s.add_dependency "dalli", "~> 1.0.5"
  s.add_dependency "lrucache", "~> 0.1.0"

  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_development_dependency "simplecov", "~> 0.4.2"
  s.add_development_dependency("rb-fsevent", "~> 0.4.3") if RUBY_PLATFORM =~ /darwin/i
  s.add_development_dependency "guard", "~> 0.6.2"
  s.add_development_dependency "guard-bundler", "~> 0.1.3"
  s.add_development_dependency "guard-rspec", "~> 0.4.2"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
  s.add_development_dependency "vcr", "~> 1.11.1"
  s.add_development_dependency "timecop", "~> 0.3.5"
  s.add_development_dependency "chronic", "~> 0.6.2"
end
