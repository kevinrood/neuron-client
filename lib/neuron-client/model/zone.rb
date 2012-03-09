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

      IRIS_2_0 = '2_0'
      IRIS_2_5 = '2_5'
      IRIS_VERSIONS = [IRIS_2_0, IRIS_2_5]
      TEMPLATE_SLUGS = ['300x250']
      PLAYLIST_MODES = ['MAXI', 'MINI']
      PLAYBACK_MODE_OPTIONS = [['Auto Play', 'AUTO'], ['Click To Play','CTP'], ['Rollover To Play', 'RTP']]
      PLAYBACK_MODES = Hash[PLAYBACK_MODE_OPTIONS].values
      OVERLAY_PROVIDERS = ['NAMI', 'PREDICTV']

      ATTRIBUTES = [
        :id,
        :ad_links,
        :name,
        :response_type, # string in RESPONSE_TYPES
        :template_slug, # nil, or string in TEMPLATE_SLUGS
        :channel,       # nil, or slug
        :expand,        # nil, or "Yes" or "No"
        :iris_version,  # nil, or string in IRIS_VERSIONS
        # Iris 2.0
        :mute,          # nil, or "Yes" or "No"
        :autoplay,      # nil, or "Yes" or "No"
        # Iris 2.5
        :playlist_mode, # nil, or string in PLAYLIST_MODES
        :volume,        # nil, or 1-100s
        :color,         # nil, or string (hex color - '333333')
        :playback_mode, # nil, or string in PLAYBACK_MODES
        :overlay_provider, # nil, or string in OVERLAY_PROVIDERS
        :overlay_feed_url, # nil, or string URL

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

      STATISTIC_TYPES = %w(requests blocks defaults unitloads selections undeliveries impressions redirects clicks)

      def recent(statistic, parameters={})
        connected_to_admin!
        by = (parameters[:by] || parameters['by']).to_s
        minutes = parameters[:minutes] || parameters['minutes']
        group_by = parameters[:group_by] || parameters['group_by']
        parameters = {}
        parameters['by'] = by unless by.blank?
        parameters['minutes'] = minutes.to_i if minutes.to_i > 0
        parameters['group_by'] = group_by.to_s unless group_by.blank?
        if validate?
          unless STATISTIC_TYPES.include?(statistic.to_s)
            raise "Unsupported statistic: #{statistic}"
          end
          unless by.blank? || by == 'zone'
            raise "Unsupported by: #{by}"
          end
          unless minutes.blank? || minutes.to_i > 0
            raise "Unsupported minutes: #{minutes}"
          end
          unless group_by.blank? || group_by == 'hour'
            raise "Unsupported group_by: #{group_by}"
          end
        end

        connection.get("zones/#{id}/recent/#{statistic}", parameters)
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
