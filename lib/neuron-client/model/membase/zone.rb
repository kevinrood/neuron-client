module Neuron
  module Client
    module Model
      module Membase
        class Zone < Common::Zone
          class << self
            def find(id)
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