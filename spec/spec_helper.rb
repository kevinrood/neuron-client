require 'rubygems'
require 'bundler'

Bundler.require(:default, :test, :development)

SimpleCov.start do
  add_filter "/spec/"
  add_group "Models", "lib"
end

Neuron::Client::API.configure do |config|
  config.admin_url = "https://example.com"
  config.admin_key = "secret"
end