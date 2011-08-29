module Neuron
  module Client
    module Admin
      module Ad

        # deliveries
        attr_accessor :total_impressed, :today_impressed

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