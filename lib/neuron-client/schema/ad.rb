module Neuron
  module Schema
    class Ad
      include Common

      SCHEMA = self.new

      def index
        @@index ||=
        set_of(object_type("ad",
          :id => id,
          :name => nullable_string
        ))
      end

      def create
        @@create ||=
        one_of(
          create_redirect,
          create_video_ad,
          create_vast_network,
          create_acudeo_network
        )
      end

      def show
        @@show ||=
        one_of(
          show_redirect,
          show_video_ad,
          show_vast_network,
          show_acudeo_network
        )
      end

      def update
        @@update ||=
        one_of(
          update_redirect,
          update_video_ad,
          update_vast_network,
          update_acudeo_network
        )
      end

      # --------------------

      def create_redirect
        @@create_redirect ||=
        object_type("ad", merged(CREATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Ad::REDIRECT]),
          :redirect_url  => SCHEMA.url,
        }))
      end

      def create_video_ad
        @@create_video_ad ||=
        object_type("ad", merged(CREATE_PROPERTIES,{
          :response_type      => SCHEMA.choice_of([Neuron::Client::Ad::VIDEO_AD]),
          :video_flv_url      => SCHEMA.url(:required => false),
          :clickthru_url      => SCHEMA.url(:required => false),
          :companion_ad_html  => SCHEMA.companion_ad_html(:required => false),
          :social_urls        => SCHEMA.social_urls(:required => false),
          :vast_tracker_urls  => SCHEMA.vast_tracker_urls(:required => false),
        }))
      end

      def create_vast_network
        @@create_vast_network ||=
        object_type("ad", merged(CREATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Ad::VAST_NETWORK]),
          :vast_url      => SCHEMA.url,
        }))
      end

      def create_acudeo_network
        @@create_acudeo_network ||=
        object_type("ad", merged(CREATE_PROPERTIES,{
          :response_type     => SCHEMA.choice_of([Neuron::Client::Ad::ACUDEO_NETWORK]),
          :acudeo_program_id => SCHEMA.slug,
        }))
      end

      def show_redirect
        @@show_redirect ||=
        object_type("ad", merged(SHOW_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Ad::REDIRECT]),
          :redirect_url  => SCHEMA.url,
        }))
      end

      def show_video_ad
        @@show_video_ad ||=
        object_type("ad", merged(SHOW_PROPERTIES,{
          :response_type      => SCHEMA.choice_of([Neuron::Client::Ad::VIDEO_AD]),
          :video_flv_url      => SCHEMA.url,
          :clickthru_url      => SCHEMA.url,
          :companion_ad_html  => SCHEMA.companion_ad_html,
          :social_urls        => SCHEMA.social_urls,
          :vast_tracker_urls  => SCHEMA.vast_tracker_urls,
        }))
      end

      def show_vast_network
        @@show_vast_network ||=
        object_type("ad", merged(SHOW_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Ad::VAST_NETWORK]),
          :vast_url      => SCHEMA.url,
        }))
      end

      def show_acudeo_network
        @@show_acudeo_network ||=
        object_type("ad", merged(SHOW_PROPERTIES,{
          :response_type     => SCHEMA.choice_of([Neuron::Client::Ad::ACUDEO_NETWORK]),
          :acudeo_program_id => SCHEMA.slug,
        }))
      end

      def update_redirect
        @@update_redirect ||=
        object_type("ad", merged(UPDATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Ad::REDIRECT], :required => false),
          :redirect_url  => SCHEMA.url(:required => false),
        }))
      end

      def update_video_ad
        @@update_video_ad ||=
        object_type("ad", merged(UPDATE_PROPERTIES,{
          :response_type      => SCHEMA.choice_of([Neuron::Client::Ad::VIDEO_AD], :required => false),
          :video_flv_url      => SCHEMA.url(:required => false),
          :clickthru_url      => SCHEMA.url(:required => false),
          :companion_ad_html  => SCHEMA.companion_ad_html(:required => false),
          :social_urls        => SCHEMA.social_urls(:required => false),
          :vast_tracker_urls  => SCHEMA.vast_tracker_urls(:required => false),
        }))
      end

      def update_vast_network
        @@update_vast_network ||=
        object_type("ad", merged(UPDATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Ad::VAST_NETWORK], :required => false),
          :vast_url      => SCHEMA.url(:required => false),
        }))
      end

      def update_acudeo_network
        @@update_acudeo_network ||=
        object_type("ad", merged(UPDATE_PROPERTIES,{
          :response_type     => SCHEMA.choice_of([Neuron::Client::Ad::ACUDEO_NETWORK], :required => false),
          :acudeo_program_id => SCHEMA.slug(:required => false),
        }))
      end

      # --------------------

      def companion_ad_html(overrides={})
        merged({
          :type => %w(string null),
          :required => true
        }, overrides)
      end

      def daily_cap(overrides={})
        merged({
          :type => %w(integer string null),
          :required => true,
          :minimum => 1,
          :exclusiveMinimum => false,
          :pattern => "^[1-9]\\d*$"
        }, overrides)
      end

      def day_partitions(overrides={})
        merged({
          :type => ["string","null"],
          :required => true,
          :minLength => 168,
          :maxLength => 168,
          :pattern => "^[TF]+$"
        }, overrides)
      end

      def frequency_cap(overrides={})
        merged({
          :type => ["object","null"],
          :additionalProperties => false,
          :required => true,
          :properties => {
            :limit => {
              :type => %w(integer string),
              :minimum => 1,
              :maximum => 10,
              :required => true,
              :enum => (1..10).to_a + (1..10).map(&:to_s)
            },
            :window => choice_of(Neuron::Client::Ad::FREQUENCY_CAP_WINDOWS)
          }
        }, overrides)
      end

      def geo_target_netacuity_ids(overrides={})
        properties = {}
        Neuron::Client::GeoTarget::TYPES.each do |geo_type|
          properties[geo_type] = set_of(integer, :required => false)
        end
        merged({
          :type => "object",
          :required => true,
          :additionalProperties => false,
          :properties => properties
        }, overrides)
      end
      
      def ideal_impressions_per_hour(overrides={})
        merged({
          :type => %w(number string null),
          :required => true,
          :minimum => 0,
          :exclusiveMinimum => true,
          :pattern => "^\\d+(\\.\\d+)?$"
        }, overrides)
      end

      def overall_cap(overrides={})
        merged({
          :type => %w(integer string null),
          :required => true,
          :minimum => 1,
          :exclusiveMinimum => false,
          :pattern => "^[1-9]\\d*$"
        }, overrides)
      end

      def social_urls(overrides={})
        properties = {}
        Neuron::Client::Ad::SOCIAL_TYPES.each do |social_type|
          properties[social_type] = url(:required => false)
        end
        merged({
          :type => "object",
          :required => true,
          :additionalProperties => false,
          :properties => properties
        }, overrides)
      end

      def vast_tracker_urls(overrides={})
        properties = {}
        Neuron::Client::Ad::VAST_TRACKER_TYPES.each do |tracker_type|
          properties[tracker_type] = set_of(url, :required => false)
        end
        merged({
          :type => "object",
          :required => true,
          :additionalProperties => false,
          :properties => properties
        }, overrides)
      end

      def zone_links(overrides={})
        merged({
          :type => "object",
          :required => true,
          :additionalProperties => false,
          :patternProperties => {
            "^\\w+$" => {
              :description => "property name is a zone id",
              :type => "object",
              :required => true,
              :additionalProperties => false,
              :properties => {
                :priority => priority,
                :weight => weight
              }
            }
          }
        }, overrides)
      end

      # --------------------

      private

      CREATE_PROPERTIES =
        {
          :approved                   => SCHEMA.yes_no(                    :required => true),
          :daily_cap                  => SCHEMA.daily_cap(                 :required => false),
          :day_partitions             => SCHEMA.day_partitions(            :required => false),
          :end_datetime               => SCHEMA.datetime(                  :required => false, :type => %w(string null)),
          :frequency_cap              => SCHEMA.frequency_cap(             :required => false),
          :geo_target_netacuity_ids   => SCHEMA.geo_target_netacuity_ids(  :required => false),
          :ideal_impressions_per_hour => SCHEMA.ideal_impressions_per_hour(:required => false),
          :name                       => SCHEMA.nullable_string(           :required => false),
          :overall_cap                => SCHEMA.overall_cap(               :required => false),
          :pixel_ids                  => SCHEMA.set_of(SCHEMA.id,          :required => false),
          :start_datetime             => SCHEMA.datetime(                  :required => true),
          :time_zone                  => SCHEMA.timezone(                  :required => true),
          :zone_links                 => SCHEMA.zone_links(                :required => false),

          :id                         => SCHEMA.missing_or_null,
          :created_at                 => SCHEMA.missing_or_null,
          :updated_at                 => SCHEMA.missing_or_null,
          :total_impressed            => SCHEMA.missing_or_null,
          :today_impressed            => SCHEMA.missing_or_null,

          :response_type              => SCHEMA.choice_of([]),

          # Redirect:
          :redirect_url               => SCHEMA.missing_or_null,

          # VastNetwork:
          :vast_url                   => SCHEMA.missing_or_null,

          # AcudeoNetwork:
          :acudeo_program_id          => SCHEMA.missing_or_null,

          # VideoAd:
          :video_flv_url              => SCHEMA.missing_or_null,
          :clickthru_url              => SCHEMA.missing_or_null,
          :companion_ad_html          => SCHEMA.missing_or_null,
          :social_urls                => SCHEMA.missing_or_null_or_empty_hash,
          :vast_tracker_urls          => SCHEMA.missing_or_null_or_empty_hash,
        }
      
      SHOW_PROPERTIES =
        {
          :approved                   => SCHEMA.yes_no(                    :required => true),
          :daily_cap                  => SCHEMA.daily_cap(                 :required => true),
          :day_partitions             => SCHEMA.day_partitions(            :required => true),
          :end_datetime               => SCHEMA.datetime(                  :required => true, :type => %w(string null)),
          :frequency_cap              => SCHEMA.frequency_cap(             :required => true),
          :geo_target_netacuity_ids   => SCHEMA.geo_target_netacuity_ids(  :required => true),
          :ideal_impressions_per_hour => SCHEMA.ideal_impressions_per_hour(:required => true),
          :name                       => SCHEMA.nullable_string(           :required => true),
          :overall_cap                => SCHEMA.overall_cap(               :required => true),
          :pixel_ids                  => SCHEMA.set_of(SCHEMA.id,          :required => true),
          :start_datetime             => SCHEMA.datetime(                  :required => true),
          :time_zone                  => SCHEMA.timezone(                  :required => true),
          :zone_links                 => SCHEMA.zone_links(                :required => true),

          :id                         => SCHEMA.id(                    :required => true),
          :created_at                 => SCHEMA.datetime(              :required => true),
          :updated_at                 => SCHEMA.datetime(              :required => true),
          :total_impressed            => SCHEMA.integer(:minimum => 0, :required => true),
          :today_impressed            => SCHEMA.integer(:minimum => 0, :required => true),

          :response_type              => SCHEMA.choice_of([], :required => true),

          # Redirect:
          :redirect_url               => SCHEMA.missing_or_null,

          # VastNetwork:
          :vast_url                   => SCHEMA.missing_or_null,

          # AcudeoNetwork:
          :acudeo_program_id          => SCHEMA.missing_or_null,

          # VideoAd:
          :video_flv_url              => SCHEMA.missing_or_null,
          :clickthru_url              => SCHEMA.missing_or_null,
          :companion_ad_html          => SCHEMA.missing_or_null,
          :social_urls                => SCHEMA.missing_or_null_or_empty_hash,
          :vast_tracker_urls          => SCHEMA.missing_or_null_or_empty_hash,
        }
      
      UPDATE_PROPERTIES =
        {
          :id                         => SCHEMA.id(:required => true),

          :approved                   => SCHEMA.yes_no(                    :required => false),
          :daily_cap                  => SCHEMA.daily_cap(                 :required => false),
          :day_partitions             => SCHEMA.day_partitions(            :required => false),
          :end_datetime               => SCHEMA.datetime(                  :required => false, :type => %w(string null)),
          :frequency_cap              => SCHEMA.frequency_cap(             :required => false),
          :geo_target_netacuity_ids   => SCHEMA.geo_target_netacuity_ids(  :required => false),
          :ideal_impressions_per_hour => SCHEMA.ideal_impressions_per_hour(:required => false),
          :name                       => SCHEMA.nullable_string(           :required => false),
          :overall_cap                => SCHEMA.overall_cap(               :required => false),
          :pixel_ids                  => SCHEMA.set_of(SCHEMA.id,          :required => false),
          :start_datetime             => SCHEMA.datetime(                  :required => false),
          :time_zone                  => SCHEMA.timezone(                  :required => false),
          :zone_links                 => SCHEMA.zone_links(                :required => false),
          
          :response_type              => SCHEMA.choice_of([], :required => false),

          # Redirect:
          :redirect_url               => SCHEMA.missing_or_null,

          # VastNetwork:
          :vast_url                   => SCHEMA.missing_or_null,

          # AcudeoNetwork:
          :acudeo_program_id          => SCHEMA.missing_or_null,

          # VideoAd:
          :video_flv_url              => SCHEMA.missing_or_null,
          :clickthru_url              => SCHEMA.missing_or_null,
          :companion_ad_html          => SCHEMA.missing_or_null,
          :social_urls                => SCHEMA.missing_or_null_or_empty_hash,
          :vast_tracker_urls          => SCHEMA.missing_or_null_or_empty_hash,
        }
    end
  end
end