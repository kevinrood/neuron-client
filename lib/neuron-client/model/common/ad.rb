module Neuron
  module Client
    module Model
      module Common
        class Ad
          include Base
          include AdCalculations

          resource_name("ad")
          resources_name("ads")

          attr_accessor :name, :approved, :response_type, :parameters, :geo_target_ids, :ad_trackers,
              :ad_trackers_attributes,
            # redirect
              :redirect_url,
            # video
              :video_api_url, :video_setup_xml, :video_flv_url,
              :video_clickthru_url, :video_companion_ad_html, :social_links, :social_links_attributes,
            # caps
              :frequency_cap_limit, :frequency_cap_window, :overall_cap,
              :daily_cap, :day_partitions, :ideal_impressions_per_hour,
            # range
              :start_datetime, :end_datetime, :time_zone,
            # timestamps
              :created_at, :updated_at

          class << self
            def stringify_day_partitions(days)
              result = ""
              168.times do |i|
                result << (days[i.to_s] || "F")
              end
              result
            end
          end
        end
      end
    end
  end
end