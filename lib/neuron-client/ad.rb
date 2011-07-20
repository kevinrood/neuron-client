module Neuron
  module Client
    class Ad
      include Connected
      resource_name("ad")
      resources_name("ads")

      attr_accessor :errors
      attr_accessor :name, :approved, :response_type, :parameters, 
        # redirect
          :redirect_url,
        # video
          :video_api_url, :video_setup_xml, :video_flv_url, 
          :video_clickthru_url, :video_companion_ad_html,
        # caps
          :frequency_cap_limit, :frequency_cap_window, :overall_cap, 
          :daily_cap, :day_partitions, :ideal_impressions_per_hour,
        # range
          :start_datetime, :end_datetime, :time_zone,
        # timestamps
          :created_at, :updated_at

      def valid?
        validate
        @errors.empty?
      end
      
      def self.stringify_day_partitions(days)
        result = ""
        168.times do |i|
          result << (days[i.to_s] || "F")
        end
        result
      end
      
      def validate
        @errors = []
        @errors << [:approved, "is not 'Yes' or 'No'"] if ["Yes", "No"].include?(@approved)
        @errors << [:response_type, "is not 'Redirect' or 'Video'"] if ["Redirect", "Video"].include?(@response_type)
        @errors << [:start_datetime, "is required"] if @start_datetime.blank?
        @errors << [:end_datetime, "is required"] if @end_datetime.blank?
        @errors << [:time_zone, "is required"] if @time_zone.blank?
        
        if @response_type == "Video"
          @errors << [:video_api_url, "is required"] if @video_api_url.blank?
          @errors << [:video_setup_xml, "is required"] if @video_setup_xml.blank?
        elsif @response_type == "Redirect"
          @errors << [:redirect_url, "is required"] if @redirect_url.blank?
        end

        @errors << [:day_partitions, "Must be exactly 168 TF characters"] if !@day_partitions.blank? && @day_partitions.length != 168 && !(@day_partitions.match(/[TF]+/).try(:to_a).try(:first) == @day_partitions)
      end

      def unlink(ad_id)
        self.class.connection.delete("ads/#{id}/zones/#{ad_id}")
      end
    end
  end
end