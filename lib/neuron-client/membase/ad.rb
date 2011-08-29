module Neuron
  module Client
    module Membase
      module Ad

        def total_impressed
          key = "count_delivery_ad_#{self.id}"
          Neuron::Client::Ad.connection.get(key).to_f
        end

        def today_impressed
          now_adjusted_for_ad_time_zone = Time.now.in_time_zone(self.time_zone)
          formatted_date = now_adjusted_for_ad_time_zone.strftime('%Y%m%d') # format to YYYYMMDD
          key = "count_delivery_#{formatted_date}_ad_#{self.id}"
          Neuron::Client::Ad.connection.get(key).to_f
        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def find(id)
            ad = nil
            cached_json = self.connection.get(membase_key(id))
            ad = self.new(Yajl.load(cached_json)[self.resource_name]) if cached_json.present?
            ad
          end

          def membase_key(id)
            "Ad:#{id}"
          end
        end

      end
    end
  end
end