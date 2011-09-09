module Neuron
  module Client
    class API
      autoload :OpenStruct, "ostruct"
      attr_accessor :connection

      def configure
        yield config
        inclusion(config, :connection_type, [:admin, :membase])

        configure_admin_connection if config.connection_type == :admin
        configure_membase_connection if config.connection_type == :membase

        self
      end

      def connection_type
        @config.connection_type
      end

      private

      def config
        @config ||= OpenStruct.new
      end

      def required(obj, attrib)
        val = obj.send(attrib)
        if val.nil? || (val.respond_to?(:empty?) && val.empty?)
          raise "Missing: #{attrib}"
        end
      end

      def inclusion(obj, attrib, valid_values)
        val = obj.send(attrib)
        raise "Inclusion: #{attrib} must be one of #{valid_values.join(', ')}" if !valid_values.include?(val)
      end

      def configure_admin_connection
        required(config, :admin_url)
        required(config, :admin_key)
        begin
          URI.parse(config.admin_url)
        rescue
          raise "Invalid admin_url: #{config.admin_url}"
        end
        self.connection = AdminConnection.new(config.admin_url, config.admin_key)
      end

      def configure_membase_connection
        required(@config, :membase_servers)
        self.connection = MembaseConnection.new(config.membase_servers,
          :local_cache_size => config.local_cache_size,
          :local_cache_expires => config.local_cache_expires
        )
      end

      class << self
        attr_accessor :default_api
      end
    end

    API.default_api = API.new
  end
end
