module Neuron
  module Client
    class GeoTarget
      include Connected
      resource_name("geo_target")
      resources_name("geo_targets")

      attr_accessor :geo_type, :full_name, :name, :abbreviation, :updated_at

      def self.query(parameters)
        response = self.connection.get("geo_targets", parameters)
        response.map{|hash| self.new(hash[self.resource_name])}
      end
    end
  end
end