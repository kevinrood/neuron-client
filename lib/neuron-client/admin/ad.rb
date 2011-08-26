module Neuron
  module Client
    module Admin
      module Ad

        def recent(statistic, parameters)
          self.class.connection.get("ads/#{id}/recent/#{statistic}", parameters)
        end

        def unlink(ad_id)
          self.class.admin_connection.delete("ads/#{id}/zones/#{ad_id}")
        end

      end
    end
  end
end