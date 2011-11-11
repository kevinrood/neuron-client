module Neuron
  module Client
    module Model
      module Membase
        class Zone < Common::Zone

          ADS_BY_PRIORITY_TTL = 60

          def ads_by_priority
            self.class.connection.fetch("Zone:#{id}:ads_by_priority", ADS_BY_PRIORITY_TTL) do
              calculate_ads_by_priority
            end
          end

          class << self
            def find(id)
              self.connection.local_cache.fetch("Neuron::Client::Model::Zone:#{id}") do
                zone = nil
                membase_key = "Zone:#{id}"
                cached_json = self.connection.get(membase_key)
                zone = self.new(Yajl.load(cached_json)[superclass.resource_name]) if cached_json.present?
                zone
              end
            end
          end
        end
      end
    end
  end
end