module Neuron
  module Client
    module Model
      module Admin
        class AdZone < Common::AdZone
          include Base

          def self.unlink(ad_id, zone_id)
            self.connection.delete("zones/#{zone_id}/ads/#{ad_id}")
          end
        end
      end
    end
  end
end