module Neuron
  module Client
    module Membase
      module Zone

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def find(id)
            zone = nil
            cached_json = self.connection.get(membase_key(id))
            zone = self.new(Yajl.load(cached_json)[self.resource_name]) if cached_json.present?
            zone
          end

          def membase_key(id)
            "Zone:#{id}"
          end
        end

      end
    end
  end
end