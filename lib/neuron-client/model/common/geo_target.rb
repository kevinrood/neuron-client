module Neuron
  module Client
    module Model
      module Common
        class GeoTarget
          include Base

          resource_name("geo_target")
          resources_name("geo_targets")

          attr_accessor :geo_type, :full_name, :name, :abbreviation, :updated_at
        end
      end
    end
  end
end