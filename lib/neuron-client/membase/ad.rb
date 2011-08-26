module Neuron
  module Client
    module Membase
      module Ad

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def find(id)
            cached_json = self.connection.get(cache_key(id))
            (cached_json.present? ? self.new(Yajl.load(cached_json)[self.resource_name]) : nil)
          end

          def cache_key(id)
            "Ad:#{id}"
          end
        end

      end
    end
  end
end