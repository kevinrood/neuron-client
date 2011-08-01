module Neuron
  module Client
    class BlockedReferer
      include Connected
      resource_name("blocked_referer")
      resources_name("blocked_referers")

      attr_accessor :referer, :reversed_referer, :created_at, :updated_at

    end
  end
end