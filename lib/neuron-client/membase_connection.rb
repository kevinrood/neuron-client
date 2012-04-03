require 'dalli'
require 'lrucache'

module Neuron
  module Client
    class MembaseConnection

      attr_reader :client, :local_cache

      def initialize(servers, opts={})
        @client = Dalli::Client.new(servers)
        max_items   = opts[:local_cache_max_items]    || 10_000
        ttl         = opts[:local_cache_ttl]          || 15.minutes
        soft_ttl    = [opts[:local_cache_soft_ttl]    || 1.minute, ttl].min
        retry_delay = [opts[:local_cache_retry_delay] || 1.second, soft_ttl].min
        @local_cache = LRUCache.new(
          :max_items => max_items,
          :ttl => ttl,
          :soft_ttl => soft_ttl,
          :retry_delay => retry_delay)
      end

      def get(key, ttl=nil)
        ttl = local_ttl(ttl)
        soft_ttl =[@local_cache.soft_ttl, ttl].compact.min
        retry_delay = [@local_cache.retry_delay, soft_ttl].compact.min
        @local_cache.fetch(key,
                           :ttl => ttl,
                           :soft_ttl => soft_ttl,
                           :retry_delay => retry_delay) do
          @client.get(key)
        end
      end

      def fetch(key, ttl=nil, options=nil, &callback)
        ttl = local_ttl(ttl)
        soft_ttl =[@local_cache.soft_ttl, ttl].compact.min
        retry_delay = [@local_cache.retry_delay, soft_ttl].compact.min
        @local_cache.fetch(key,
                           :ttl => ttl,
                           :soft_ttl => soft_ttl,
                           :retry_delay => retry_delay) do
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