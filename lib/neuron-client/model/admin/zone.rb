module Neuron
  module Client
    module Model
      module Admin
        class Zone < Common::Zone
          include Base

          def unlink(ad_id)
            self.class.connection.delete("zones/#{id}/ads/#{ad_id}")
          end
        end
      end
    end
  end
end