module Neuron
  module Schema
    class Zone
      include Common

      SCHEMA = self.new

      def index
        @@index ||=
        set_of(object_type("zone",
          :id => uuid,
          :name => nullable_string
        ))
      end

      def create
        @@create ||=
        one_of(
          create_redirect,
          create_iris_2_0,
          create_iris_2_5,
          create_vast
        )
      end

      def show
        @@show ||=
        one_of(
          show_redirect,
          show_iris_2_0,
          show_iris_2_5,
          show_vast
        )
      end

      def update
        @@update ||=
        one_of(
          update_redirect,
          update_iris_2_0,
          update_iris_2_5,
          update_vast
        )
      end

      # --------------------

      def create_redirect
        @@create_redirect ||=
        object_type("zone", merged(CREATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::REDIRECT]),
        }))
      end

      def create_iris_2_0
        @@create_iris_2_0 ||=
        object_type("zone", merged(CREATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::IRIS]),
          :iris_version  => SCHEMA.choice_of([Neuron::Client::Zone::IRIS_2_0], :required => false),
          :template_slug => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS),
          :channel       => SCHEMA.channel,
          :expand        => SCHEMA.yes_no,
          :mute          => SCHEMA.yes_no,
          :autoplay      => SCHEMA.yes_no
        }))
      end

      def create_iris_2_5
        @@create_iris_2_5 ||=
        object_type("zone", merged(CREATE_PROPERTIES,{
          :response_type    => SCHEMA.choice_of([Neuron::Client::Zone::IRIS]),
          :iris_version     => SCHEMA.choice_of([Neuron::Client::Zone::IRIS_2_5]),
          :template_slug    => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS),
          :channel          => SCHEMA.channel,
          :expand           => SCHEMA.yes_no,
          :playlist_mode    => SCHEMA.playlist_mode,
          :volume           => SCHEMA.volume,
          :color            => SCHEMA.color(:required => false),
          :playback_mode    => SCHEMA.playback_mode,
          :overlay_provider => SCHEMA.overlay_provider(:type => %w(null string), :required => false),
          :overlay_feed_url => SCHEMA.url(:type => %w(null string), :required => false)
        }))
      end

      def create_vast
        @@create_vast ||=
        object_type("zone", merged(CREATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::VAST]),
        }))
      end

      def show_redirect
        @@show_redirect ||=
        object_type("zone", merged(SHOW_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::REDIRECT]),
        }))
      end

      def show_iris_2_0
        @@show_iris_2_0 ||=
        object_type("zone", merged(SHOW_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::IRIS]),
          :iris_version  => SCHEMA.choice_of([Neuron::Client::Zone::IRIS_2_0], :required => false),
          :template_slug => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS),
          :channel       => SCHEMA.channel,
          :expand        => SCHEMA.yes_no,
          :mute          => SCHEMA.yes_no,
          :autoplay      => SCHEMA.yes_no
        }))
      end

      def show_iris_2_5
        @@show_iris_2_5 ||=
        object_type("zone", merged(SHOW_PROPERTIES,{
          :response_type    => SCHEMA.choice_of([Neuron::Client::Zone::IRIS]),
          :iris_version     => SCHEMA.choice_of([Neuron::Client::Zone::IRIS_2_5]),
          :template_slug    => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS),
          :channel          => SCHEMA.channel,
          :expand           => SCHEMA.yes_no,
          :playlist_mode    => SCHEMA.playlist_mode,
          :volume           => SCHEMA.volume,
          :color            => SCHEMA.color,
          :playback_mode    => SCHEMA.playback_mode,
          :overlay_provider => SCHEMA.overlay_provider(:type => %w(null string)),
          :overlay_feed_url => SCHEMA.url(:type => %w(null string))
        }))
      end

      def show_vast
        @@show_vast ||=
        object_type("zone", merged(SHOW_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::VAST]),
        }))
      end

      def update_redirect
        @@update_redirect ||=
        object_type("zone", merged(UPDATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::REDIRECT], :required => false),
        }))
      end

      def update_iris_2_0
        @@update_iris_2_0 ||=
        object_type("zone", merged(UPDATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::IRIS], :required => false),
          :iris_version  => SCHEMA.choice_of([Neuron::Client::Zone::IRIS_2_0], :required => false),
          :template_slug => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS, :required => false),
          :channel       => SCHEMA.channel(:required => false),
          :expand        => SCHEMA.yes_no(:required => false),
          :mute          => SCHEMA.yes_no(:required => false),
          :autoplay      => SCHEMA.yes_no(:required => false)
        }))
      end

      def update_iris_2_5
        @@update_iris_2_5 ||=
        object_type("zone", merged(UPDATE_PROPERTIES,{
          :response_type    => SCHEMA.choice_of([Neuron::Client::Zone::IRIS], :required => false),
          :iris_version     => SCHEMA.choice_of([Neuron::Client::Zone::IRIS_2_5], :required => false),
          :template_slug    => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS, :required => false),
          :channel          => SCHEMA.channel(:required => false),
          :expand           => SCHEMA.yes_no(:required => false),
          :playlist_mode    => SCHEMA.playlist_mode(:required => false),
          :volume           => SCHEMA.volume(:required => false),
          :color            => SCHEMA.color(:required => false),
          :playback_mode    => SCHEMA.playback_mode(:required => false),
          :overlay_provider => SCHEMA.overlay_provider(:type => %w(null string), :required => false),
          :overlay_feed_url => SCHEMA.url(:type => %w(null string), :required => false)
        }))
      end

      def update_vast
        @@update_vast ||=
        object_type("zone", merged(UPDATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::VAST], :required => false),
        }))
      end

      # --------------------

      def ad_links(overrides={})
        merged({
          :type => "object",
          :required => true,
          :additionalProperties => false,
          :patternProperties => {
            "^[0-9]+$" => {
              :description => "property name is an ad id",
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

      def channel(overrides={})
        merged({
          :type => "string",
          :pattern => "^\\w+$",
          :minLength => 1,
          :maxLength => 255
        }, overrides)
      end

      def color(overrides={})
        merged({
          :type => %w(string null),
          :format => "color",
          :required => true
        }, overrides)
      end

      def overlay_provider(overrides={})
        choice_of(Neuron::Client::Zone::OVERLAY_PROVIDERS, overrides)
      end

      def playback_mode(overrides={})
        choice_of(Neuron::Client::Zone::PLAYBACK_MODES, overrides)
      end

      def playlist_mode(overrides={})
        choice_of(Neuron::Client::Zone::PLAYLIST_MODES, overrides)
      end

      def volume(overrides={})
        merged({
          :type => %w(integer string null),
          :required => true,
          :minimum => 0,
          :exclusiveMinimum => false,
          :maximum => 100,
          :exclusiveMaximum => false,
          :pattern => "^[0-9]\\d+$",
          :maxLength => 3
        }, overrides)
      end

      # --------------------

      private

      CREATE_PROPERTIES =
        {
          :name          => SCHEMA.nullable_string(:required => false),
          :ad_links      => SCHEMA.ad_links(:required => false),
          :response_type => SCHEMA.choice_of([], :required => true),
          :iris_version  => SCHEMA.missing_or_null,
          :template_slug => SCHEMA.missing_or_null,
          :channel       => SCHEMA.missing_or_null,
          :expand        => SCHEMA.missing_or_null,
          # Iris 2.0
          :mute             => SCHEMA.missing_or_null,
          :autoplay         => SCHEMA.missing_or_null,
          # Iris 2.5
          :playlist_mode    => SCHEMA.missing_or_null,
          :volume           => SCHEMA.missing_or_null,
          :color            => SCHEMA.missing_or_null,
          :playback_mode    => SCHEMA.missing_or_null,
          :overlay_provider => SCHEMA.missing_or_null,
          :overlay_feed_url => SCHEMA.missing_or_null,

        }

      SHOW_PROPERTIES =
        {
          :id         => SCHEMA.uuid(:required => true),
          :created_at => SCHEMA.datetime(:required => true),
          :updated_at => SCHEMA.datetime(:required => true),

          :name          => SCHEMA.nullable_string(:required => true),
          :ad_links      => SCHEMA.ad_links(:required => true),
          :response_type => SCHEMA.choice_of([], :required => true),
          :iris_version  => SCHEMA.missing_or_null,
          :template_slug => SCHEMA.missing_or_null,
          :channel       => SCHEMA.missing_or_null,
          :expand        => SCHEMA.missing_or_null,
          # Iris 2.0
          :mute             => SCHEMA.missing_or_null,
          :autoplay         => SCHEMA.missing_or_null,
          # Iris 2.5
          :playlist_mode    => SCHEMA.missing_or_null,
          :volume           => SCHEMA.missing_or_null,
          :color            => SCHEMA.missing_or_null,
          :playback_mode    => SCHEMA.missing_or_null,
          :overlay_provider => SCHEMA.missing_or_null,
          :overlay_feed_url => SCHEMA.missing_or_null,
        }

      UPDATE_PROPERTIES =
        {
          :id         => SCHEMA.uuid(:required => true),

          :name          => SCHEMA.nullable_string(:required => false),
          :ad_links      => SCHEMA.ad_links(:required => false),
          :response_type => SCHEMA.choice_of([], :required => false),
          :iris_version  => SCHEMA.missing_or_null,
          :template_slug => SCHEMA.missing_or_null,
          :channel       => SCHEMA.missing_or_null,
          :expand        => SCHEMA.missing_or_null,
          # Iris 2.0
          :mute             => SCHEMA.missing_or_null,
          :autoplay         => SCHEMA.missing_or_null,
          # Iris 2.5
          :playlist_mode    => SCHEMA.missing_or_null,
          :volume           => SCHEMA.missing_or_null,
          :color            => SCHEMA.missing_or_null,
          :playback_mode    => SCHEMA.missing_or_null,
          :overlay_provider => SCHEMA.missing_or_null,
          :overlay_feed_url => SCHEMA.missing_or_null,
        }
    end
  end
end