module Neuron
  module Client
    module Membase
      module GeoTarget

        def self.query(parameters)
          response = self.admin_connection.get("geo_targets", parameters)
          response.map{|hash| self.new(hash[self.resource_name])}
        end

      end
    end
  end
end