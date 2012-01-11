require 'map'
require 'deep_merge/core'
require 'tzinfo'

module Neuron
  module Schema
    module Common
      module ClassMethods
        def schema
          @schema ||= "#{self.name}::SCHEMA".constantize
        end

        def validate!(schema_name, data)
          JSON::Validator.validate!(schema.send(schema_name), data)
        rescue Exception => e
          puts "Data: #{data}"
          raise e
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      def object_type(name, properties)
        Map.new(
          :type => "object",
          :additionalProperties => false,
          :required => true,
          :properties => {
            name => {
              :type => "object",
              :required => true,
              :additionalProperties => false,
              :properties => properties
            }
          }
        )
      end

      def object_type_or_null(name, properties)
        merged(object_type(name, properties), {:properties => {name => {:type => %w(object null)}}})
      end

      def merged(*hashes)
        result = Map.new
        hashes.each do |hash|
          result = ::DeepMerge::deep_merge!(hash, result, {:preserve_unmergeables => false})
        end
        result
      end

      def choice_of(choices, overrides={})
        merged({
          :type => "string",
          :enum => choices,
          :required => true
        }, overrides)
      end

      def one_of(*schemas)
        merged({:type => schemas}, {})
      end

      def set_of(schema, overrides={})
        merged({
            :type => "array",
            :additionalItems => false,
            :uniqueItems => true,
            :required => true,
            :items => schema
        }, overrides)
      end

      def datetime(overrides={})
        merged({
          :type => "string",
          :format => "date-time",
          :pattern => "^\\d{4}-[01]?\\d-[0-3]?\\dT[012]?\\d:[0-5]?\\d:[0-5]?\\dZ$",
          :required => true
        }, overrides)
      end

      def errors
        merged({
          :type => "object",
          :required => true,
          :additionalProperties => {
            :type => "array",
            :minItems => 1,
            :items => {
              :type => "string",
              :required => true
            }
          }
        }, {})
      end

      def id(overrides={})
        merged({
          :type => %w(integer string),
          :required => true,
          :pattern => "^\\d+$"
        }, overrides)
      end

      def integer(overrides={})
        merged({
          :type => %w(integer string),
          :required => true,
          :pattern => "^\\-?\\d+$"
        }, overrides)
      end

      def missing_or_null
        merged({
          :type => "null",
          :required => false
        }, {})
      end

      def missing_or_null_or_empty_hash
        merged({
          :type => %w(object null),
          :additionalProperties => false,
          :required => false
        }, {})
      end

      def nonnull_string(overrides={})
        merged({
          :type => "string",
          :maxLength => 255,
          :required => "true"
        }, overrides)
      end

      def null
        merged({
          :type => "null",
          :required => true
        }, {})
      end
      
      def nullable_string(overrides={})
        merged({
          :type => %w(string null),
          :maxLength => 255,
          :required => true
        }, overrides)
      end

      def parameters(parameters, overrides={})
        merged({
          :type => "object",
          :required => true,
          :additionalProperties => false,
          :properties => parameters
        }, overrides)
      end

      def priority(overrides={})
        merged({
          :type => %w(integer string),
          :required => true,
          :minimum => 1,
          :maximum => 10,
          :enum => (1..10).to_a + (1..10).map(&:to_s)
        }, overrides)
      end

      def slug(overrides={})
        merged({
          :type => "string",
          :required => true,
          :pattern => "^\\w+$",
          :maxLength => 255,
          :minLength => 1
        }, overrides)
      end

      def timezone(overrides={})
        choice_of(Neuron::Client::Ad::TIME_ZONES, overrides)
      end

      def url(overrides={})
        merged({
          :type => "string",
          :format => "uri",
          :pattern => "^https?:\/\/",
          :maxLength => 2000,
          :required => true
        }, overrides)
      end

      def uuid(overrides={})
        merged({
          :type => "string",
          :pattern => "^[a-z0-9]+$",
          :maxlength => 25,
          :required => true
        }, overrides)
      end

      def weight(overrides={})
        merged({
          :type => %w(number string),
          :required => true,
          :minimum => -1000,
          :maximum => 1000,
          :pattern => "^\\-?\\d+(\\.\\d+)?$"
        }, overrides)
      end

      def yes_no(overrides={})
        choice_of(%w(Yes No), overrides)
      end
    end
  end
end