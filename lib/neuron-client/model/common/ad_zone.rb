module Neuron
  module Client
    module Model
      module Common
        class AdZone
          include Base

          resource_name("ad_zone")
          resources_name("ad_zones")

          attr_accessor :ad_id, :zone_id, :priority, :weight,
              :created_at, :updated_at
        end
      end
    end
  end
end