module Neuron
  module Client
    module Model
      module Admin
        class GeoTarget < Common::GeoTarget
          include Base

          def self.query(parameters)
            response = self.connection.get("geo_targets", parameters)
            response.map{|hash| self.new(hash[superclass.resource_name])}
          end
        end
      end
    end
  end
end