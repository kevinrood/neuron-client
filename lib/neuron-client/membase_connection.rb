require 'dalli'
require 'lrucache'

module Neuron
  module Client
    class MembaseConnection

      attr_reader :client, :local_cache

      def initialize(servers, opts={})
        @client = Dalli::Client.new(servers)
        @local_cache = LRUCache.new(
          :max_items => opts[:local_cache_size],
          :ttl => opts[:local_cache_expires] || 60.seconds)
      end

      def get(key, ttl=nil)
        @local_cache.fetch(key, local_ttl(ttl)) do
          @client.get(key)
        end
      end

      def fetch(key, ttl=nil, options=nil, &callback)
        @local_cache.fetch(key, local_ttl(ttl)) do
          @client.fetch(key, ttl, options, &callback)
        end
      end

      private

      def local_ttl(ttl)
        return nil if ttl.nil?
        ttl = Float(ttl)
        local_ttl = @local_cache.ttl
        if local_ttl.nil? || local_ttl == 0 || local_ttl > ttl
          ttl
        else
          nil
        end
      end
    end
  end
end