module Neuron
  module Client
    class GeoTarget
      include Base

      TYPES = %w(COUNTRY REGION METRO CITY) # DO NOT modify, unless you're absolutely sure of all the ramifications!

      ATTRIBUTES = [
        :id,
        :geo_type,      # string, one of TYPES
        :net_acuity_id, # integer
        :abbreviation,  # string
        :full_name,     # string
        :name,          # string
      ]

      attr_accessor *ATTRIBUTES

      def attributes
        ATTRIBUTES
      end

      EXPECTED_QUERY_PARAMS = %w(geo_type search limit)
      def self.query(parameters)
        if validate?
          unless parameters.all?{|k,v| EXPECTED_QUERY_PARAMS.include?(k.to_s)}
            raise "Unsupported parameters: #{parameters.inspect}"
          end
        end
        data = self.connection.get("geo_targets", parameters)
        validate_against_schema!(:index, data)
        data.map{ |hash| from_hash(hash) }
      end
    end
  end
end