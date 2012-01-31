require 'json-schema'

module Neuron
  module Schema
    describe Zone do
      before(:each) do
        @datetime = "2011-11-11T11:11:11Z"
        @monkey_wrench = {"monkey_wrench" => {"id" => 42, "name" => "a"}}
        @monkey_wrenches = [
          {"monkey_wrench" => {"id" => 1, "name" => "a"}},
          {"monkey_wrench" => {"id" => 2, "name" => "b"}},
          {"monkey_wrench" => {"id" => 3, "name" => "c"}}
        ]
      end

      def validate(data, opts={})
        schema = opts[:against] || raise("You forgot to specify the schema!")
        JSON::Validator.validate!(schema, data)
      end

      def invalidate(data, opts={})
        schema = opts[:against] || raise("You forgot to specify the schema!")
        JSON::Validator.validate(schema, data).should be_false
      end

      describe "index" do
        it "should approve an example list of zones" do
          validate(
            [{"zone" => {"id" => "abc123", "name" => nil}},
             {"zone" => {"id" => "efg456", "name" => nil}},
             {"zone" => {"id" => "hij789", "name" => nil}}
            ],
            :against => Zone::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => Zone::SCHEMA.index)
        end

        it "should not approve an example zone outside of a list" do
          invalidate(
            {"zone" => {"id" => "abc123", "name" => "fred"}},
            :against => Zone::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => Zone::SCHEMA.index)
        end
      end

      describe "create" do
        it "should approve an example redirect zone" do
          validate({"zone" => {
            "name" => "example_redirect_zone",
            "response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}}
          }}, :against => Zone::SCHEMA.create)
        end

        it "should approve an example iris 2.0 zone" do
          validate({"zone" => {
            "name" => "example_iris_zone",
            "response_type" => "Iris",
            "ad_links" => {},
            "expand" => "Yes",
            "mute" => "No",
            "autoplay" => "Yes",
            "channel" => "drivel",
            "template_slug" => "300x250"
          }}, :against => Zone::SCHEMA.create)
        end

        it "should approve an example iris 2.5 zone" do
          validate({"zone" => {
            "name" => "example_iris_zone",
            "response_type" => "Iris",
            "ad_links" => {},
            "expand" => "Yes",
            "channel" => "drivel",
            "template_slug" => "300x250",
            "playlist_mode" => "MAXI",
            "playback_mode" => "AUTO",
            "volume" => "10",
            "color" => "#FF0000",
            "iris_version" => "2_5"
          }}, :against => Zone::SCHEMA.create)
        end

        it "should approve an example vast zone" do
          validate({"zone" => {
            "name" => "example_vast_zone",
            "response_type" => "Vast",
            "ad_links" => {}
          }}, :against => Zone::SCHEMA.create)
        end

        it "should not approve a zone with missing information" do
          invalidate({"zone" => {
            "name" => "example_redirect_zone",
            #"response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}}
          }}, :against => Zone::SCHEMA.create)
        end

        it "should not approve a zone with extra information" do
          invalidate({"zone" => {
            "name" => "example_redirect_zone",
            "response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}},
            "channel" => "extra"
          }}, :against => Zone::SCHEMA.create)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Zone::SCHEMA.create)
        end
      end

      describe "show" do
        it "should approve an example redirect zone" do
          validate({"zone" => {
            "name" => "example_redirect_zone",
            "response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}},
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.show)
        end

        it "should approve an example iris 2.0 zone" do
          validate({"zone" => {
            "name" => "example_iris_zone",
            "response_type" => "Iris",
            "ad_links" => {},
            "expand" => "Yes",
            "mute" => "No",
            "autoplay" => "Yes",
            "channel" => "drivel",
            "template_slug" => "300x250",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.show)
        end

        it "should approve an example iris 2.5 zone" do
          validate({"zone" => {
            "name" => "example_iris_zone",
            "response_type" => "Iris",
            "ad_links" => {},
            "expand" => "Yes",
            "channel" => "drivel",
            "template_slug" => "300x250",
            "playlist_mode" => "MAXI",
            "playback_mode" => "AUTO",
            "volume" => "10",
            "color" => "#FF0000",
            "overlay_provider" => "NAMI",
            "overlay_feed_url" => "http://example.com/",
            "iris_version" => "2_5",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.show)
        end

        it "should approve an example vast zone" do
          validate({"zone" => {
            "name" => "example_vast_zone",
            "response_type" => "Vast",
            "ad_links" => {},
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.show)
        end

        it "should not approve a zone with missing information" do
          invalidate({"zone" => {
            #"name" => "example_redirect_zone",
            "response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}},
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.show)
        end

        it "should not approve a zone with extra information" do
          invalidate({"zone" => {
            "name" => "example_redirect_zone",
            "response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}},
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => "abc123",
            "channel" => "extra"
          }}, :against => Zone::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Zone::SCHEMA.show)
        end
      end

      describe "update" do
        it "should approve an example redirect zone" do
          validate({"zone" => {
            "name" => "example_redirect_zone",
            "response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}},
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.update)
        end

        it "should approve an example iris 2.0 zone" do
          validate({"zone" => {
            "name" => "example_iris_zone",
            "response_type" => "Iris",
            "ad_links" => {},
            "expand" => "Yes",
            "mute" => "No",
            "autoplay" => "Yes",
            "channel" => "drivel",
            "template_slug" => "300x250",
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.update)
        end

        it "should approve an example iris 2.5 zone" do
          validate({"zone" => {
            "name" => "example_iris_zone",
            "response_type" => "Iris",
            "ad_links" => {},
            "expand" => "Yes",
            "channel" => "drivel",
            "template_slug" => "300x250",
            "playlist_mode" => "MAXI",
            "playback_mode" => "AUTO",
            "volume" => "10",
            "color" => "#FF0000",
            "overlay_provider" => "NAMI",
            "overlay_feed_url" => "http://example.com/",
            "iris_version" => "2_5",
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.update)
        end

        it "should approve an example vast zone" do
          validate({"zone" => {
            "name" => "example vast zone",
            "response_type" => "Vast",
            "ad_links" => {},
            "id" => "abc123"
          }}, :against => Zone::SCHEMA.update)
        end

        it "should not approve a zone with missing id" do
          invalidate({"zone" => {
            "name" => "example_redirect_zone",
            "response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}},
            #"id" => "abc123"
          }}, :against => Zone::SCHEMA.update)
        end

        it "should not approve a zone with extra information" do
          invalidate({"zone" => {
            "name" => "example_redirect_zone",
            "response_type" => "Redirect",
            "ad_links" => {"1" => {"weight" => 1.5, "priority" => 1},
                           "2" => {"weight" => 2.5, "priority" => 2}},
            "id" => "abc123",
            "channel" => "drivel"
          }}, :against => Zone::SCHEMA.update)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Zone::SCHEMA.update)
        end
      end
    end
  end
end