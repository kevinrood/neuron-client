module Neuron
  module Client
    class AdZone
      include Connected
      resource_name("ad_zone")
      resources_name("ad_zones")

      attr_accessor :ad_id, :zone_id, :priority, :weight,
          :created_at, :updated_at

      def self.unlink(ad_id, zone_id)
        self.connection.delete("zones/#{zone_id}/ads/#{ad_id}")
      end
    end
  end
end