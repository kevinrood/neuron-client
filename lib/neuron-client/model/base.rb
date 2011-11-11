module Neuron
  module Client
    module Model
      class Base
        instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id|^class$)/ }

        def initialize(attrs=nil)
          @proxied_model = self.class.class_to_proxy.new(attrs)
        end

        def method_missing(meth, *args, &block)
          (@proxied_model.respond_to?(meth) ? @proxied_model.send(meth, *args, &block) : super)
        end

        class << self
          attr_accessor :api
          def api
            @api || Neuron::Client::API.default_api
          end

          def connection
            api.connection
          end

          def class_to_proxy
            module_to_load = api.connection_type.to_s.titleize
            class_name_to_load = name.split('::').last
            Neuron::Client::Model.const_get(module_to_load).const_get(class_name_to_load)
          end

          def method_missing(meth, *args, &block)
            (class_to_proxy.respond_to?(meth) ? class_to_proxy.send(meth, *args, &block) : super)
          end
        end
      end
    end
  end
end