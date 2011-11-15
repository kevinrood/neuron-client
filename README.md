Neuron Client Gem
=================


Setup
=====

Connect to the admin server for read/write access to exposed models:

  Neuron::Client::API.default_api.configure do |config|
    config.connection_type = :admin
    config.admin_url = "https://example.com"
    config.admin_key = "secret"
  end

  Short form to copy and paste into console:

  Neuron::Client::API.default_api.configure {|config| config.connection_type = :admin; config.admin_url = 'http://localhost:3000'; config.admin_key = 'secret'}


Connect to the Membase (or Memcached) Server for limited read access to some exposed models:

  Neuron::Client::API.default_api.configure do |config|
    config.connection_type = :membase
    config.membase_servers = "127.0.0.1:11211"
  end

  Short form to copy and paste into console:

  Neuron::Client::API.default_api.configure {|config| config.connection_type = :membase; config.membase_servers = '127.0.0.1:11211'}

Create a new API, configure and use it for one specific model:

  api = Neuron::Client::API.new
  api.configure {|config| config.connection_type = :membase; config.membase_servers = '127.0.0.1:11211'}
  Neuron::Client::Model::Ad.api = api

Zones
=====

*Note: many finder methods are not available when using a Membase connection.  Objects are read-only when using a Membase connection.

Create a zone:

    zone = Neuron::Client::Model::Zone.new(:name => 'test', :response_type => 'Redirect')
    zone.save

... or simply:
    
    Neuron::Client::Model::Zone.create(:name => 'test', :response_type => 'Redirect')

List all zones:

    Neuron::Client::Model::Zone.all # => Array of Zone objects (with limited attributes)

Find a zone by ID:

    Neuron::Client::Model::Zone.find(zone_id)

Update a zone:

    zone.update_attributes(:parameters => {'foo' => 'bar'})

TODO: Finish and finalize the API
