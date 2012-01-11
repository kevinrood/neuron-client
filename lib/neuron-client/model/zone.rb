module Neuron
  module Client
    class Zone
      include Base
      include ZoneCalculations

      ADS_BY_PRIORITY_TTL = 60 #seconds

      REDIRECT = "Redirect"
      IRIS = "Iris"
      VAST = "Vast"
      RESPONSE_TYPES = [REDIRECT, IRIS, VAST]

      TEMPLATE_SLUGS = ["300x250", "300x600"]

      ATTRIBUTES = [
        :id,
        :ad_links,
        :name,
        :response_type, # string in RESPONSE_TYPES
        :template_slug, # nil, or string in TEMPLATE_SLUGS
        :mute,          # nil, or "Yes" or "No"
        :autoplay,      # nil, or "Yes" or "No"
        :channel,       # nil, or slug
        :expand,        # nil, or "Yes" or "No"
        :text_overlay,  # nil, or "Yes" or "No"
        :nami_feed_url, # nil, or string URL
        :created_at,    # string, datetime in UTC
        :updated_at,    # string, datetime in UTC
      ]

      attr_accessor *ATTRIBUTES

      def attributes
        ATTRIBUTES
      end

      def id=(id)
        @id = id.to_s
      end

      def find_ad(ad_id)
        Ad.find(ad_id)
      end

      def unlink(ad_id)
        connected_to_admin!
        validate_id!(ad_id)
        validate_uuid!(id)
        connection.delete("zones/#{id}/ads/#{ad_id}")
      end

      def ads_by_priority
        if connected_to_membase?
          connection.fetch("Zone:#{id}:ads_by_priority", ADS_BY_PRIORITY_TTL) do
            calculate_ads_by_priority
          end
        else
          calculate_ads_by_priority
        end
      end
    end
  end
end