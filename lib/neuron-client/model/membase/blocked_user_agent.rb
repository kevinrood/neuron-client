module Neuron
  module Client
    module Model
      module Membase
        class BlockedUserAgent < Common::BlockedUserAgent
          class << self
            def all
              blocked_user_agents = []
              cached_json = self.connection.get('blocked_user_agents')
              blocked_user_agents = Yajl.load(cached_json).collect{|item| self.new(item[superclass.resource_name])} if cached_json.present?
              blocked_user_agents
            end
          end
        end
      end
    end
  end
end