module Neuron
  module Client

    # Neuron::Client::API.configure do |config|
    #   config.admin_url = "https://example.com"
    #   config.admin_key = "secret"
    # end
    # 
    # Neuron::Client::API.connection
    class API
      autoload :OpenStruct, "ostruct"
      class << self
        attr_accessor :connection

        def reset!
          self.connection = nil
          @config = nil
        end

        def configure
          @config ||= OpenStruct.new
          yield @config
          required(@config, :admin_url)
          required(@config, :admin_key)
          begin
            URI.parse(@config.admin_url)
          rescue
            raise "Invalid admin_url: #{@config.admin_url}"
          end
          self.connection = Connection.new(@config.admin_url, @config.admin_key)
          true
        end

        private

        def required(obj, attrib)
          val = obj.send(attrib)
          if val.nil? || (val.respond_to?(:empty?) && val.empty?)
            raise "Missing: #{attrib}"
          end
        end
      end
    end
  end
end
