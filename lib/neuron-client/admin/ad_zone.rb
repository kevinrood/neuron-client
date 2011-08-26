module Neuron
  module Client
    module Admin
      module AdZone

        def self.unlink(ad_id, zone_id)
          self.admin_connection.delete("zones/#{zone_id}/ads/#{ad_id}")
        end

      end
    end
  end
end