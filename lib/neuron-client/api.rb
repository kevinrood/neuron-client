module Neuron
  module Client

    # Neuron::Client::API.configure do |config|
    #   config.connection_type = :admin
    #   config.admin_url = "https://example.com"
    #   config.admin_key = "secret"
    # end
    #
    # Short form to copy and paste into console:
    #
    # Neuron::Client::API.configure {|config| config.connection_type = :admin; config.admin_url = 'http://localhost'; config.admin_key = 'secret'}
    #
    # -- OR --
    #
    # Neuron::Client::API.configure do |config|
    #   config.connection_type = :membase
    #   config.membase_servers = "127.0.0.1:11211"
    # end
    #
    # Short form to copy and paste into console:
    #
    # Neuron::Client::API.configure {|config| config.connection_type = :membase; config.membase_servers = '127.0.0.1:11211'}
    #
    class API
      autoload :OpenStruct, "ostruct"
      class << self
        attr_accessor :connection

        def configure
          @config ||= OpenStruct.new
          yield @config
          inclusion(@config, :connection_type, [:admin, :membase])

          configure_admin_connection if @config.connection_type == :admin
          configure_membase_connection if @config.connection_type == :membase

          load_connection_specific_modules
          true
        end

        def connection_type
          @config.connection_type
        end

        private

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
          required(@config, :admin_url)
          required(@config, :admin_key)
          begin
            URI.parse(@config.admin_url)
          rescue
            raise "Invalid admin_url: #{@config.admin_url}"
          end
          self.connection = Admin::Connection.new(@config.admin_url, @config.admin_key)
        end

        def configure_membase_connection
          required(@config, :membase_servers)
          self.connection = Membase::Connection.new(@config.membase_servers)
        end

        def load_connection_specific_modules
          case connection_type
            when :admin
              Ad.class_exec do
                include(Admin::Base)
                include(Admin::Ad)
              end

              AdZone.class_exec do
                include(Admin::Base)
                include(Admin::AdZone)
              end

              BlockedReferer.class_exec do
                include(Admin::Base)
                include(Admin::BlockedReferer)
              end

              BlockedUserAgent.class_exec do
                include(Admin::Base)
                include(Admin::BlockedUserAgent)
              end

              GeoTarget.class_exec do
                include(Admin::Base)
                include(Admin::GeoTarget)
              end

              Report.class_exec do
                include(Admin::Base)
                include(Admin::Report)
              end

              S3File.class_exec do
                include(Admin::Base)
                include(Admin::S3File)
              end

              Zone.class_exec do
                include(Admin::Base)
                include(Admin::Zone)
              end
            when :membase
              Ad.class_exec do
                include(Membase::Base)
                include(Membase::Ad)
              end

              AdZone.class_exec do
                include(Membase::Base)
                include(Membase::AdZone)
              end

              BlockedReferer.class_exec do
                include(Membase::Base)
                include(Membase::BlockedReferer)
              end

              BlockedUserAgent.class_exec do
                include(Membase::Base)
                include(Membase::BlockedUserAgent)
              end

              GeoTarget.class_exec do
                include(Membase::Base)
                include(Membase::GeoTarget)
              end

              Report.class_exec do
                include(Membase::Base)
                include(Membase::Report)
              end

              S3File.class_exec do
                include(Membase::Base)
                include(Membase::S3File)
              end

              Zone.class_exec do
                include(Membase::Base)
                include(Membase::Zone)
              end
          end
        end
      end

    end
  end
end
