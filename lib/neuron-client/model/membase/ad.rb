module Neuron
  module Client
    module Model
      module Membase
        class Ad < Common::Ad

          ACTIVE_TTL = 60 #seconds
          PRESSURE_TTL = 60 #seconds

          def total_impressed
            key = "count_delivery_ad_#{self.id}"
            self.class.connection.get(key).to_f
          end

          def today_impressed
            now_adjusted_for_ad_time_zone = Time.now.in_time_zone(self.time_zone)
            formatted_date = now_adjusted_for_ad_time_zone.strftime('%Y%m%d') # format to YYYYMMDD
            key = "count_delivery_#{formatted_date}_ad_#{self.id}"
            self.class.connection.get(key).to_f
          end

          def active?
            self.class.connection.fetch("Ad:#{id}:active", ACTIVE_TTL) do
              calculate_active?(Time.now, total_impressed, today_impressed)
            end
          end

          def pressure
            self.class.connection.fetch("Ad:#{id}:pressure", PRESSURE_TTL) do
              calculate_pressure(Time.now, total_impressed, today_impressed)
            end
          end

          class << self
            def find(id)
              ad = nil
              membase_key = "Ad:#{id}"
              cached_json = self.connection.get(membase_key)
              ad = self.new(Yajl.load(cached_json)[superclass.resource_name]) if cached_json.present?
              ad
            end
          end
        end
      end
    end
  end
end