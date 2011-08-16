module Neuron
  module Client
    class Zone
      include Connected
      resource_name("zone")
      resources_name("zones")
      remote_id('uuid')

      attr_accessor :slug, :response_type, :template_slug, :parameters,
          :created_at, :updated_at

      def unlink(ad_id)
        self.class.connection.delete("zones/#{id}/ads/#{ad_id}")
      end
    end
  end
end