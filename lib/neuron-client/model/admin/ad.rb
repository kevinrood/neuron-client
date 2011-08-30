module Neuron
  module Client
    module Model
      module Admin
        class Ad < Common::Ad
          include Base

          # deliveries
          attr_accessor :total_impressed, :today_impressed

          def recent(statistic, parameters)
            self.class.connection.get("ads/#{id}/recent/#{statistic}", parameters)
          end

          def unlink(zone_id)
            self.class.connection.delete("ads/#{id}/zones/#{zone_id}")
          end
        end
      end
    end
  end
end