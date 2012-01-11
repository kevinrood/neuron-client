module Neuron
  module Client
    class BlockedUserAgent
      include Base

      ATTRIBUTES = [
        :id,
        :user_agent,  # string, regex (max 2 GB length)
        :description, # nil, or string (max 2 GB length)
        :created_at,  # string, datetime in UTC
        :updated_at,  # string, datetime in UTC
      ]

      attr_accessor *ATTRIBUTES
      
      def attributes
        ATTRIBUTES
      end
    end
  end
end