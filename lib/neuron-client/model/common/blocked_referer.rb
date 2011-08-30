module Neuron
  module Client
    module Model
      module Common
        class BlockedReferer
          include Base

          resource_name("blocked_referer")
          resources_name("blocked_referers")

          attr_accessor :referer, :reversed_referer, :created_at, :updated_at
        end
      end
    end
  end
end