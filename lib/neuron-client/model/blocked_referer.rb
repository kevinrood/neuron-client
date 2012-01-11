module Neuron
  module Client
    class BlockedReferer
      include Base

      ATTRIBUTES = [
        :id,
        :referer, # string, URL
        :created_at, # string, datetime in UTC
        :updated_at, # string, datetime in UTC
      ]

      attr_accessor *ATTRIBUTES
      
      def attributes
        ATTRIBUTES
      end
    end
  end
end