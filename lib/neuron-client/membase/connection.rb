require 'dalli'

module Neuron
  module Client
    module Membase
      class Connection

        attr_reader :membase

        def initialize(servers)
          @membase = Dalli::Client.new(servers)
        end

        def get(key)
          @membase.get(key)
        end

      end
    end
  end
end