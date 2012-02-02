module Neuron
  module Client
    module Base

      module ClassAndInstanceMethods

        def find(id)
          if connected_to_membase?
            key = cache_key(id)
            connection.local_cache.fetch(key) do
              cached_json = connection.get(key)
              if cached_json.present?
                data = Yajl.load(cached_json)
                validate_against_schema!(:show, data)
                from_hash(data)
              end
            end
          elsif connected_to_admin?
            data = connection.get("#{resources_name}/#{id}")
            validate_against_schema!(:show, data)
            from_hash(data)
          else
            raise "Not configured!"
          end
        end

        def all
          if connected_to_membase?
            key = cache_key(":all")
            connection.local_cache.fetch(key) do
              cached_json = connection.get(resources_name)
              if cached_json.present?
                data = Yajl.load(cached_json)
                validate_against_schema!(:index, data)
                data.map{ |hash| from_hash(hash) }
              else
                []
              end
            end
          elsif connected_to_admin?
            data = connection.get(resources_name)
            validate_against_schema!(:index, data)
            data.map{ |hash| from_hash(hash) }
          else
            raise "Not configured!"
          end
        end

        def create(attrs={})
          @errors = catch :errors do
            return create!(attrs)
          end
          from_hash(resource_name => {'errors' => @errors})
        end

        def create!(attrs={})
          data = {resource_name => attrs.stringify_keys}
          validate_against_schema!(:create, data)
          data = connection.post("#{resources_name}", data)
          validate_against_schema!(:show, data)
          from_hash(data)
        end

        def api=(api)
          @api = api
        end

        def validate=(validate)
          @validate = validate
        end

        protected

        ID_PATTERN = /\A\d+\z/.freeze
        def validate_id!(id)
          if validate?
            unless (id.is_a?(Integer) || ID_PATTERN.match(id.to_s)) && id.to_i > 0
              raise "Invalid ID: #{id.inspect}"
            end
          end
        end

        UUID_PATTERN = /\A[a-z0-9]+\z/.freeze
        def validate_uuid!(uuid)
          if validate?
            unless UUID_PATTERN.match(uuid) && uuid.length <= 25
              raise "Invalid UUID: #{uuid}"
            end
          end
        rescue Exception => e
          raise "Invalid UUID: #{uuid}"
        end

        # schema_name : one of [:index, :show, :create, update]
        # data : the serializable object that should match the given schema
        def validate_against_schema!(schema_name, data)
          if validate? && data.present?
            begin
              JSON::Validator.validate!(schema.send(schema_name), data)
            rescue Exception => e
              e.message << "\nSchema: #{schema.class.name}::SCHEMA.#{schema_name}\nData: #{data.inspect}"
              raise e
            end
          end
        end

        def from_hash(hash)
          if hash.present?
            attrs = hash[resource_name]
            klass.new(attrs) if attrs.present?
          end
        end

        def api
          if self.is_a?(Class)
            @api || Neuron::Client::API.default_api
          else
            @api || self.class.api
          end
        end

        def validate?
          return !!@validate unless @validate.nil?
          if self.is_a?(Class)
            api.validate?
          else
            self.class.validate?
          end
        end

        def connection
          api.connection
        end

        def connected?
          connection.present?
        end

        def connected_to_admin?
          api.connection_type == :admin && connected?
        end

        def connected_to_membase?
          api.connection_type == :membase && connected?
        end

        def connected_to_admin!
          raise("Not configured for admin server!") unless connected_to_admin?
        end

        def connected_to_membase!
          raise("Not configured for membase server!") unless connected_to_membase?
        end

        def klass
          @klass ||= (self.is_a?(Class) ? self : self.class)
        end

        def schema
          @schema ||= "Neuron::Schema::#{klass.name.demodulize}::SCHEMA".constantize
        end

        def cache_key(id)
          "#{klass.name.demodulize}:#{id}"
        end

        def resource_name
          @resource_name ||= klass.name.demodulize.underscore
        end

        def resources_name
          @resources_name ||= resource_name.pluralize
        end
     end

      def self.included(base)
        base.send(:attr_accessor, :errors) if base.is_a?(Class)
        base.send(:attr_reader, :id) if base.is_a?(Class)
        base.extend(ClassAndInstanceMethods)
      end

      include ClassAndInstanceMethods

      def initialize(attrs={})
        apply_attributes!(attrs)
      end

      def apply_attributes!(attrs)
        if attrs.present?
          attrs.each do |k,v|
            self.send("#{k}=", v) if self.respond_to?("#{k}=")
          end
        end
      end

      def to_hash(*except)
        hash = {}
        except = except.map(&:to_sym)
        attributes.each do |attribute|
          unless except.include?(attribute.to_sym)
            value = send(attribute)
            hash[attribute.to_s] = value
          end
        end
        {resource_name => hash}
      end

      def to_create_hash(*except)
        to_hash(*([:errors, :updated_at, :created_at, :id] + except))
      end

      def to_update_hash(*except)
        to_hash(*([:errors, :updated_at, :created_at] + except))
      end

      def new_record?
        id.nil?
      end

      def id=(id)
        @id = Integer(id)
      end

      def save
        update_attributes
      end

      def update_attributes(attrs={})
        connected_to_admin!
        @errors = catch :errors do
          apply_attributes!(attrs) if attrs.present?
          data = {}
          if new_record?
            data = to_create_hash
            validate_against_schema!(:create, data)
            data = connection.post(resources_name, data)
          else
            data = to_update_hash
            validate_against_schema!(:update, data)
            data = connection.put("#{resources_name}/#{id}", data)
          end
          apply_attributes!(data[resource_name])
          []
        end
        @errors.empty?
      end

      def valid?
        @errors.empty?
      end

      def destroy
        connected_to_admin!
        connection.delete("#{resources_name}/#{id}")
      end
    end
  end
end