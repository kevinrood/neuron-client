module Neuron
  module Client
    module Base

      def initialize(attrs=nil)
        (attrs || {}).each do |k,v|
          next if k.to_s == 'id' && self.class.remote_id != 'id'
          k = 'id' if k.to_s == self.class.remote_id
          self.send("#{k}=", v) if self.respond_to?("#{k}=")
        end
      end

      def self.included(base)
        base.send(:attr_accessor, :id)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def attr_accessor(*vars)
          @attributes ||= []
          @attributes += vars
          super(*vars)
        end

        def attributes
          @attributes
        end

        def connection
          API.connection
        end

        def resource_name(res=nil)
          if res
            @resource_name = res.to_s
          end
          @resource_name
        end

        def resources_name(res=nil)
          if res
            @resources_name = res.to_s.downcase
          end
          if @resources_name.nil? && !@resource_name.nil?
            @resources_name = "#{@resource_name}s"
          end
          @resources_name
        end

        def remote_id(remote_id=nil)
          if remote_id
            @remote_id = remote_id.to_s
          end
          @remote_id || 'id'
        end
      end

    end
  end
end