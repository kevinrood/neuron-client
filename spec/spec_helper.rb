require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_group "Models", "lib"
end

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test, :development)


Neuron::Client::API.configure do |c|
  c.admin_url = "http://127.0.0.1:3000"
  c.admin_key = "secret"
end

VCR.config do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__),'fixtures','vcr_cassettes')
  c.stub_with :fakeweb
  c.default_cassette_options = {:record => :new_episodes}
  c.ignore_localhost = false
  c.allow_http_connections_when_no_cassette = false
end
