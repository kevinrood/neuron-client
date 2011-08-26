module Neuron
  module Client
    class Zone
      include Connected
      resource_name("zone")
      resources_name("zones")

      attr_accessor :slug, :response_type, :template_slug, :parameters,
          :created_at, :updated_at, :ad_links

      def unlink(ad_id)
        self.class.connection.delete("zones/#{id}/ads/#{ad_id}")
      end

      def find_ad(ad_id)
        Ad.find(ad_id)
      end
    end
  end
end