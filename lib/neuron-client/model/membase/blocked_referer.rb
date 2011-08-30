module Neuron
  module Client
    module Model
      module Membase
        class BlockedReferer < Common::BlockedReferer
          class << self
            def all
              blocked_referers = []
              cached_json = self.connection.get('blocked_referers')
              blocked_referers = Yajl.load(cached_json).collect{|item| self.new(item[superclass.resource_name])} if cached_json.present?
              blocked_referers
            end
          end
        end
      end
    end
  end
end