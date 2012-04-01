Neuron Client Gem
=================


Setup
=====

Connect to the admin server for read/write access to exposed models:

  Neuron::Client::API.default_api.configure do |config|
    config.connection_type = :admin
    config.admin_url = "https://example.com"
    config.admin_key = "secret"
    config.validate = (ENV['RAILS_ENV'] != 'production')
  end

  Short form to copy and paste into console:

  Neuron::Client::API.default_api.configure {|config| config.connection_type = :admin; config.admin_url = 'http://localhost:3000'; config.admin_key = 'secret'}


Connect to the Membase (or Memcached) Server for limited read access to some exposed models:

  Neuron::Client::API.default_api.configure do |config|
    config.connection_type = :membase
    config.membase_servers = "127.0.0.1:11211"
    config.local_cache_ttl = 15.minutes
    config.local_cache_soft_ttl = 1.minute
    config.local_cache_retry_delay = 1.second
    config.local_cache_max_items = 10_000
  end

  Short form to copy and paste into console:

  Neuron::Client::API.default_api.configure {|config| config.connection_type = :membase; config.membase_servers = '127.0.0.1:11211'}

Create a new API, configure and use it for one specific model:

  api = Neuron::Client::API.new
  api.configure do |config|
    config.connection_type = :membase
    config.membase_servers = '127.0.0.1:11211'
  end
  Neuron::Client::Ad.api = api

Zones
=====

*Note: many finder methods are not available when using a Membase connection.  Objects are read-only when using a Membase connection.

Create a zone:

    zone = Neuron::Client::Zone.new(:name => 'test', :response_type => 'Redirect', :redirect_url => 'http://example.com')
    zone.save

... or simply:
    
    Neuron::Client::Zone.create(:name => 'test', :response_type => 'Redirect', :redirect_url => 'http://example.com')

List all zones:

    Neuron::Client::Zone.all # => Array of Zone objects (with limited attributes)

Find a zone by ID:

    Neuron::Client::Zone.find(zone_id)

Update a zone:

    zone.update_attributes(:redirect_url => 'http://example.com/store')

