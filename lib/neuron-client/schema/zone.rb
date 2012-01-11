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
          create_iris,
          create_vast
        )
      end

      def show
        @@show ||=
        one_of(
          show_redirect,
          show_iris,
          show_vast
        )
      end

      def update
        @@update ||=
        one_of(
          update_redirect,
          update_iris,
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

      def create_iris
        @@create_iris ||=
        object_type("zone", merged(CREATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::IRIS]),
          :template_slug => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS),
          :mute          => SCHEMA.yes_no,
          :autoplay      => SCHEMA.yes_no,
          :channel       => SCHEMA.channel,
          :expand        => SCHEMA.yes_no,
          :text_overlay  => SCHEMA.yes_no,
          :nami_feed_url => SCHEMA.url(:type => %w(string null), :required => false)
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

      def show_iris
        @@show_iris ||=
        object_type("zone", merged(SHOW_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::IRIS]),
          :template_slug => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS),
          :mute          => SCHEMA.yes_no,
          :autoplay      => SCHEMA.yes_no,
          :channel       => SCHEMA.channel,
          :expand        => SCHEMA.yes_no,
          :text_overlay  => SCHEMA.yes_no,
          :nami_feed_url => SCHEMA.url(:type => %w(string null))
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

      def update_iris
        @@update_iris ||=
        object_type("zone", merged(UPDATE_PROPERTIES,{
          :response_type => SCHEMA.choice_of([Neuron::Client::Zone::IRIS], :required => false),
          :template_slug => SCHEMA.choice_of(Neuron::Client::Zone::TEMPLATE_SLUGS, :required => false),
          :mute          => SCHEMA.yes_no(:required => false),
          :autoplay      => SCHEMA.yes_no(:required => false),
          :channel       => SCHEMA.channel(:required => false),
          :expand        => SCHEMA.yes_no(:required => false),
          :text_overlay  => SCHEMA.yes_no(:required => false),
          :nami_feed_url => SCHEMA.url(:type => %w(string null), :required => false)
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

      # --------------------

      private


      CREATE_PROPERTIES =
        {
          :name          => SCHEMA.nullable_string(:required => false),
          :ad_links      => SCHEMA.ad_links(:required => false),
          :response_type => SCHEMA.choice_of([], :required => true),
          :template_slug => SCHEMA.missing_or_null,
          :mute          => SCHEMA.missing_or_null,
          :autoplay      => SCHEMA.missing_or_null,
          :channel       => SCHEMA.missing_or_null,
          :expand        => SCHEMA.missing_or_null,
          :text_overlay  => SCHEMA.missing_or_null,
          :nami_feed_url => SCHEMA.missing_or_null,
        }

      SHOW_PROPERTIES =
        {
          :id         => SCHEMA.uuid(:required => true),
          :created_at => SCHEMA.datetime(:required => true),
          :updated_at => SCHEMA.datetime(:required => true),

          :name          => SCHEMA.nullable_string(:required => true),
          :ad_links      => SCHEMA.ad_links(:required => true),
          :response_type => SCHEMA.choice_of([], :required => true),
          :template_slug => SCHEMA.missing_or_null,
          :mute          => SCHEMA.missing_or_null,
          :autoplay      => SCHEMA.missing_or_null,
          :channel       => SCHEMA.missing_or_null,
          :expand        => SCHEMA.missing_or_null,
          :text_overlay  => SCHEMA.missing_or_null,
          :nami_feed_url => SCHEMA.missing_or_null,
        }

      UPDATE_PROPERTIES =
        {
          :id         => SCHEMA.uuid(:required => true),

          :name          => SCHEMA.nullable_string(:required => false),
          :ad_links      => SCHEMA.ad_links(:required => false),
          :response_type => SCHEMA.choice_of([], :required => false),
          :template_slug => SCHEMA.missing_or_null,
          :mute          => SCHEMA.missing_or_null,
          :autoplay      => SCHEMA.missing_or_null,
          :channel       => SCHEMA.missing_or_null,
          :expand        => SCHEMA.missing_or_null,
          :text_overlay  => SCHEMA.missing_or_null,
          :nami_feed_url => SCHEMA.missing_or_null,
        }
    end
  end
end