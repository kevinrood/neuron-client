module Neuron
  module Client
    class Ad
      include Base
      include AdCalculations

      ACTIVE_TTL = 60 #seconds
      PRESSURE_TTL = 60 #seconds

      REDIRECT       = 'Redirect'
      VIDEO_AD       = 'VideoAd'
      VAST_NETWORK   = 'VastNetwork'
      ACUDEO_NETWORK = 'AcudeoNetwork'
      RESPONSE_TYPES = [REDIRECT, VIDEO_AD, VAST_NETWORK, ACUDEO_NETWORK]
      
      SOCIAL_TYPES = %w(facebook googleplus twitter youtube)
      TIME_ZONES = ActiveSupport::TimeZone.all.collect{|tz| tz.name }
      FREQUENCY_CAP_WINDOWS = %w(Day Hour)
      FREQUENCY_CAP_VALUES = (1..100).to_a
      VAST_TRACKER_TYPES = %w(impression clickTracking firstQuartile midpoint thirdQuartile complete)

      ATTRIBUTES = [
        # Basics
        :id, # integer
        :approved, # "Yes" or "No"
        :daily_cap, # nil, or integer > 1
        :day_partitions, # nil, or 168 characters of "T" and "F", Sunday first
        :end_datetime, # nil, or a datetime, in UTC
        :frequency_cap, # nil, or {"limit" => 1..10, "window" => in Ad::FREQUENCY_CAP_WINDOWS}
        :geo_target_netacuity_ids, # hash, where keys are in GeoTarget::TYPES, and values are arrays of integer IDs (from NetAcuity)
        :ideal_impressions_per_hour, # nil, or number > 0
        :name, # nil, or string with 255 chars or less
        :overall_cap, # nil, or integer >= 1
        :pixel_ids, # array of integers
        :response_type, # a string, in Ad::RESPONSE_TYPES
        :start_datetime, # a datetime, in UTC
        :time_zone, # a string, in Ad::TIME_ZONES.
        :zone_links, # a hash, with zone_ids as keys, and {"priority" => integer, "weight" => number} hashes as values.

        # Timestamps
        :created_at, :updated_at, # string, datetime in UTC

        # Counts
        :today_impressed, # nil, or integer >= 0
        :total_impressed, # nil, or integer >= 0

        # "Redirect" advertisements must have:
        :redirect_url, # a URI string

        # "VideoAd" advertisements must have:
        :video_flv_url, # a URI string (no macros)
        :clickthru_url, # a URI string, perhaps with macros
        :companion_ad_html, # nil, or a string (raw html, perhaps with macros)
        :social_urls, # a hash, where keys are in Ad::SOCIAL_TYPES and values are URI strings
        :vast_tracker_urls, # a hash, where keys are in Ad::VAST_TRACKER_TYPES and values are arrays of URI strings

        # "VastNetwork" advertisements must have:
        :vast_url, # a URI string, perhaps with macros

        # "AcudeoNetwork" advertisements must have:
        :acudeo_program_id, # a slug
      ]

      attr_accessor *ATTRIBUTES

      def attributes
        ATTRIBUTES
      end

      STATISTIC_TYPES = %w(selections undeliveries impressions redirects clicks)

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

        connection.get("ads/#{id}/recent/#{statistic}", parameters)
      end

      def unlink(zone_id)
        connected_to_admin!
        validate_uuid!(zone_id)
        connection.delete("ads/#{id}/zones/#{zone_id}")
      end

      def total_impressed
        if connected_to_membase?
          key = "count_delivery_ad_#{id}"
          connection.get(key,1).to_f
        else
          @total_impressed || 0
        end
      end

      def today_impressed
        if connected_to_membase?
          now_adjusted_for_ad_time_zone = Time.now.in_time_zone(self.time_zone)
          formatted_date = now_adjusted_for_ad_time_zone.strftime('%Y%m%d') # format to YYYYMMDD
          key = "count_delivery_#{formatted_date}_ad_#{id}"
          connection.get(key,1).to_f
        else
          @today_impressed || 0
        end
      end

      def active?
        if connected_to_membase?
          connection.fetch("Ad:#{id}:active", ACTIVE_TTL) do
            calculate_active?(Time.now, total_impressed, today_impressed)
          end
        else
          calculate_active?(Time.now, total_impressed, today_impressed)
        end
      end

      def pressure
        if connected_to_membase?
          connection.fetch("Ad:#{id}:pressure", PRESSURE_TTL) do
            calculate_pressure(Time.now, total_impressed, today_impressed)
          end
        else
          calculate_pressure(Time.now, total_impressed, today_impressed)
        end
      end

      protected

      def to_update_hash(*except)
        super(:total_impressed, :today_impressed)
      end

      def to_create_hash(*except)
        super(:total_impressed, :today_impressed)
      end
    end
  end
end
