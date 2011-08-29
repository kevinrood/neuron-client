module Neuron
  module Client
    module Admin
      module Zone

        def unlink(ad_id)
          self.class.admin_connection.delete("zones/#{id}/ads/#{ad_id}")
        end

      end
    end
  end
end