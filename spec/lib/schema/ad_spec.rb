require 'json-schema'

module Neuron
  module Schema
    describe Ad do
      before(:each) do
        @timezone = "Central Time (US & Canada)"
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
        it "should approve an example list of ads" do
          validate(
            [{"ad" => {"id" => 42, "name" => "fred"}},
             {"ad" => {"id" => 82, "name" => "carl"}},
             {"ad" => {"id" => 246, "name" => "gus"}}
            ],
            :against => Ad::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => Ad::SCHEMA.index)
        end

        it "should not approve an example ad outside of a list" do
          invalidate(
            {"ad" => {"id" => 42, "name" => "fred"}},
            :against => Ad::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => Ad::SCHEMA.index)
        end
      end

      describe "create" do
        it "should approve an example redirect ad" do
          validate({"ad" => {
            "name" => "example_redirect_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$"
          }}, :against => Ad::SCHEMA.create)
        end

        it "should approve an example video ad" do
          validate({"ad" => {
            "name" => "example_video_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "VideoAd",
            "video_flv_url" => "http://cdn.example.com/content/campaigns/mortgage_backed_security/safe_bet.flv",
            "clickthru_url" => "http://bank.example.com/",
            "companion_ad_html" => '<a href="$click_url$">Invest in your future!</a>',
            "social_urls" => {"youtube" => "http://www.youtube.com/watch?v=oHg5SJYRHA0"},
            "vast_tracker_urls" => {"impression" => ["http://clickthru.example.com/thingy", "http://3rdparty.example.com/thingy"],
                                    "clickTracking" => [],
                                    "firstQuartile" => [],
                                    "midpoint" => ["http://clickthru.example.com/thingy2"],
                                    "thirdQuartile" => [],
                                    "complete" => []}
          }}, :against => Ad::SCHEMA.create)
        end

        it "should approve an example vast network ad" do
          validate({"ad" => {
            "name" => "example_vast_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "VastNetwork",
            "vast_url" => "http://vast.example.com/1234/"
          }}, :against => Ad::SCHEMA.create)
        end

        it "should approve an example acudeo network ad" do
          validate({"ad" => {
            "name" => "example_acudeo_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "AcudeoNetwork",
            "acudeo_program_id" => "abc123"
          }}, :against => Ad::SCHEMA.create)
        end

        it "should not approve an ad with missing information" do
          invalidate({"ad" => {
            "name" => "example_redirect_ad",
            #"approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$"
          }}, :against => Ad::SCHEMA.create)
        end

        it "should not approve an ad with extra information" do
          invalidate({"ad" => {
            "name" => "example_redirect_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$",
            "companion_ad_html" => '<a href="http://example.com/">clickme</a>' #extra
          }}, :against => Ad::SCHEMA.create)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Ad::SCHEMA.create)
        end
      end

      describe "show" do
        it "should approve an example redirect ad" do
          validate({"ad" => {
            "name" => "example_redirect_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$",
            "today_impressed" => 0,
            "total_impressed" => 0,
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => Ad::SCHEMA.show)
        end

        it "should approve an example video ad" do
          validate({"ad" => {
            "name" => "example_video_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "VideoAd",
            "video_flv_url" => "http://cdn.example.com/content/campaigns/mortgage_backed_security/safe_bet.flv",
            "clickthru_url" => "http://bank.example.com/",
            "companion_ad_html" => '<a href="$click_url$">Invest in your future!</a>',
            "social_urls" => {"youtube" => "http://www.youtube.com/watch?v=oHg5SJYRHA0"},
            "vast_tracker_urls" => {"impression" => ["http://clickthru.example.com/thingy", "http://3rdparty.example.com/thingy"],
                                    "clickTracking" => [],
                                    "firstQuartile" => [],
                                    "midpoint" => ["http://clickthru.example.com/thingy2"],
                                    "thirdQuartile" => [],
                                    "complete" => []},
            "today_impressed" => 0,
            "total_impressed" => 0,
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => Ad::SCHEMA.show)
        end

        it "should approve an example vast network ad" do
          validate({"ad" => {
            "name" => "example_vast_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "VastNetwork",
            "vast_url" => "http://vast.example.com/1234/",
            "today_impressed" => 0,
            "total_impressed" => 0,
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => Ad::SCHEMA.show)
        end

        it "should approve an example acudeo network ad" do
          validate({"ad" => {
            "name" => "example_acudeo_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "AcudeoNetwork",
            "acudeo_program_id" => "abc123",
            "today_impressed" => 0,
            "total_impressed" => 0,
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => Ad::SCHEMA.show)
        end

        it "should not approve an ad with missing information" do
          invalidate({"ad" => {
            #"name" => "example_redirect_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$",
            "today_impressed" => 0,
            "total_impressed" => 0,
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => Ad::SCHEMA.show)
        end

        it "should not approve an ad with extra information" do
          invalidate({"ad" => {
            "name" => "example_redirect_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$",
            "today_impressed" => 0,
            "total_impressed" => 0,
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1,
            "companion_ad_html" => '<a href="http://example.com/">clickme</a>' #extra
          }}, :against => Ad::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Ad::SCHEMA.show)
        end
      end

      describe "update" do
        it "should approve an example redirect ad" do
          validate({"ad" => {
            "name" => "example_redirect_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$",
            "id" => 1
          }}, :against => Ad::SCHEMA.update)
        end

        it "should approve an example video ad" do
          validate({"ad" => {
            "name" => "example_video_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "VideoAd",
            "video_flv_url" => "http://cdn.example.com/content/campaigns/mortgage_backed_security/safe_bet.flv",
            "clickthru_url" => "http://bank.example.com/",
            "companion_ad_html" => '<a href="$click_url$">Invest in your future!</a>',
            "social_urls" => {"youtube" => "http://www.youtube.com/watch?v=oHg5SJYRHA0"},
            "vast_tracker_urls" => {"impression" => ["http://clickthru.example.com/thingy", "http://3rdparty.example.com/thingy"],
                                    "clickTracking" => [],
                                    "firstQuartile" => [],
                                    "midpoint" => ["http://clickthru.example.com/thingy2"],
                                    "thirdQuartile" => [],
                                    "complete" => []},
            "id" => 1
          }}, :against => Ad::SCHEMA.update)
        end

        it "should approve an example vast network ad" do
          validate({"ad" => {
            "name" => "example_vast_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "VastNetwork",
            "vast_url" => "http://vast.example.com/1234/",
            "id" => 1
          }}, :against => Ad::SCHEMA.update)
        end

        it "should approve an example acudeo network ad" do
          validate({"ad" => {
            "name" => "example_acudeo_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => "FFFFFTTTTTTTTTTTTTTFFFFF" * 7,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "AcudeoNetwork",
            "acudeo_program_id" => "abc123",
            "id" => 1
          }}, :against => Ad::SCHEMA.update)
        end

        it "should not approve an ad with missing id" do
          invalidate({"ad" => {
            "name" => "example_redirect_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$",
            #"id" => 1
          }}, :against => Ad::SCHEMA.update)
        end

        it "should not approve an ad with extra information" do
          invalidate({"ad" => {
            "name" => "example_redirect_ad",
            "approved" => "Yes",
            "frequency_cap" => {"limit" => 3, "window" => "Hour"},
            "overall_cap" => 50_000_000,
            "start_datetime" => @datetime,
            "end_datetime" => nil,
            "time_zone" => @timezone,
            "day_partitions" => nil,
            "daily_cap" => 1_000_000,
            "ideal_impressions_per_hour" => nil,
            "zone_links" => {"zoneA" => {"weight" => 1.5, "priority" => 1},
                             "zoneB" => {"weight" => 2.5, "priority" => 1}},
            "geo_target_netacuity_ids" => {"COUNTRY" => [1, 2]},
            "pixel_ids" => [82,246,9000],
            "response_type" => "Redirect",
            "redirect_url" => "http://www.example.com/$zone_id$?$cachebuster$",
            "id" => 1,
            "companion_ad_html" => '<a href="http://example.com/">clickme</a>' #extra
          }}, :against => Ad::SCHEMA.update)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Ad::SCHEMA.update)
        end
      end
    end
  end
end