module Neuron
  module Client
    module Model
      module Common
        class Zone
          include Base
          include ZoneCalculations

          resource_name("zone")
          resources_name("zones")

          attr_accessor :slug, :response_type, :template_slug, :parameters,
              :created_at, :updated_at, :ad_links

          def find_ad(ad_id)
            Neuron::Client::Model::Ad.find(ad_id)
          end
        end
      end
    end
  end
end