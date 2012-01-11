module Neuron
  module Client
    class AdZone
      include Base

      ATTRIBUTES = [
        :ad_id, # integer
        :zone_id, # string, UUID
        :weight, # number
        :priority, # integer, 1..10

        :created_at, #string, datetime in UTC
        :updated_at, #string, datetime in UTC
      ]

      attr_accessor *ATTRIBUTES

      def attributes
        ATTRIBUTES
      end

      def new_record?
        true
      end

      def id
        nil
      end

      def destroy
        connected_to_admin!
        validate_id!(ad_id)
        validate_uuid!(zone_id)
        connection.delete("zones/#{zone_id}/ads/#{ad_id}")
      end
      
      def self.unlink(ad_id, zone_id)
        connected_to_admin!
        validate_id!(ad_id)
        validate_uuid!(zone_id)
        connection.delete("zones/#{zone_id}/ads/#{ad_id}")
      end
    end
  end
end