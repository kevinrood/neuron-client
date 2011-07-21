Neuron Client Gem
=================


Setup
=====

    Neuron::Client::API.configure do |config|
      config.admin_url = "https://example.com"
      config.admin_key = "secret"
    end


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
