module Neuron
  module Client
    module Admin
      module Base

        def attributes
          self.class.attributes || []
        end

        def to_hash(*except)
          hash = {}
          attributes.reject{|a| except.collect(&:to_sym).include?(a.to_sym)}.each do |attribute|
            value = send(attribute)
            hash[attribute] = value unless value.nil?
          end
          hash
        end

        def new_record?
          id.nil?
        end

        def save
          @errors = catch :errors do
            if new_record?
              response = self.class.connection.post("#{self.class.resources_name}", {self.class.resource_name => self.to_hash(:errors, :updated_at, :created_at)})
              self.id = response[self.class.resource_name][self.class.remote_id]
            else
              response = self.class.connection.put("#{self.class.resources_name}/#{id}", {self.class.resource_name => self.to_hash(:errors, :updated_at, :created_at)})
            end
            []
          end

          @errors.empty?
        end

        def update_attributes(attrs={})
          @errors = catch :errors do
            response = self.class.connection.put("#{self.class.resources_name}/#{id}", {self.class.resource_name => attrs})
            attrs.each do |key, value|
              self.send("#{key}=", value) if self.respond_to?("#{key}=")
            end
            []
          end

          @errors.empty?
        end

        def valid?
          @errors.empty?
        end

        def destroy
          self.class.connection.delete("#{self.class.resources_name}/#{id}")
        end

        def self.included(base)
          base.send(:attr_accessor, :errors)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def find(id)
            response = self.connection.get("#{self.resources_name}/#{id}")
            self.new(response[self.resource_name])
          end

          def all
            response = self.connection.get("#{self.resources_name}")
            response.map{|hash| self.new(hash[self.resource_name])}
          end

          def create(attrs={})
            @errors = catch (:errors) do
              return create!(attrs)
            end
            nil
          end

          def create!(attrs={})
            response = self.connection.post("#{self.resources_name}", {self.resource_name => attrs})
            self.new(response[self.resource_name])
          end
        end
      end
    end
  end
end
