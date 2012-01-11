module Neuron
  module Client
    class Pixel
      include Base

      ATTRIBUTES = [
        :id,
        :ad_ids,     # array of integers
      ]

      attr_accessor *ATTRIBUTES
      
      def attributes
        ATTRIBUTES
      end

      def ad_ids
        @ad_ids.nil? ? [] : @ad_ids
      end
    end
  end
end