Neuron Client Gem
=================


Setup
=====

Connect to the admin server for read/write access to exposed models:

    Neuron::Client::API.configure {|config| config.connection_type = :admin; config.admin_url = "https://example.com"; config.admin_key = "secret"}

Connect to the Membase (or Memcached) Server for limited read access to some exposed models:

    Neuron::Client::API.configure {|config| config.connection_type = :membase; config.membase_servers = '127.0.0.1:11211';}

Zones
=====

Create a zone:

    zone = Neuron::Client::Zone.new(:slug => 'test', :response_type => 'Redirect')
    zone.save

... or simply:
    
    Neuron::Client::Zone.create(:slug => 'test', :response_type => 'Redirect')

List all zones:

    Neuron::Client::Zone.all # => Array of Zone objects (with limited attributes)

Find a zone by ID:

    Neuron::Client::Zone.find(zone_id)

Update a zone:

    zone.update_attributes(:parameters => {'foo' => 'bar'})

TODO: Finish and finalize the API
