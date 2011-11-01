module Neuron
  module Client
    module Model
      module Common
        class Pixel
          include Base

          resource_name("pixel")
          resources_name("pixels")

          # time stamps
          attr_accessor :created_at, :updated_at

        end
      end
    end
  end
end