require 'dalli'

module Neuron
  module Client
    class MembaseConnection
      extend Forwardable

      attr_reader :client
      def_delegators :@client, :get, :fetch

      def initialize(servers)
        @client = Dalli::Client.new(servers)
      end

    end
  end
end