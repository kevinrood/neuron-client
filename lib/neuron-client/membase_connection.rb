require 'dalli'

module Neuron
  module Client
    class MembaseConnection

      attr_reader :client

      def initialize(servers)
        @client = Dalli::Client.new(servers)
      end

      def get(key)
        @client.get(key)
      end
    end
  end
end