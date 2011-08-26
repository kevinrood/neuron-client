module Neuron
  module Client
    class Zone
      include Base

      resource_name("zone")
      resources_name("zones")

      attr_accessor :slug, :response_type, :template_slug, :parameters,
          :created_at, :updated_at

    end
  end
end