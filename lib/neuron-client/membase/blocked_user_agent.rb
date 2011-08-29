module Neuron
  module Client
    module Membase
      module BlockedUserAgent
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def all
            blocked_user_agents = []
            cached_json = self.connection.get(all_membase_key)
            blocked_user_agents = Yajl.load(cached_json).collect{|item| self.new(item[self.resource_name])} if cached_json.present?
            blocked_user_agents
          end

          def all_membase_key
            'blocked_user_agents'
          end
        end

      end
    end
  end
end