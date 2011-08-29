module Neuron
  module Client
    module Membase
      module BlockedReferer
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def all
            blocked_referers = []
            cached_json = self.connection.get(all_membase_key)
            blocked_referers = self.new(Yajl.load(cached_json).collect{|item| BlockedReferer.new(item[self.resource_name])}) if cached_json.present?
            blocked_referers
          end

          def all_membase_key
            'blocked_referers'
          end
        end

      end
    end
  end
end