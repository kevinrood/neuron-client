require 'json-schema'

module Neuron
  module Schema
    describe Report do
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
        it "should approve an example list of reports" do
          validate(
            [{"report" => {"id" => 42,  "state" => "RUNNING", "template" => "delivery_metrics"}},
             {"report" => {"id" => 82,  "state" => "FAILED",  "template" => "post_activities"}},
             {"report" => {"id" => 246, "state" => "READY",   "template" => "ad_events"}}
            ],
            :against => Report::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => Report::SCHEMA.index)
        end

        it "should not approve an example report outside of a list" do
          invalidate(
            {"report" => {"id" => 246, "state" => "READY", "template" => "ad_events"}},
            :against => Report::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => Report::SCHEMA.index)
        end
      end

      describe "create" do
        it "should approve an example report" do
          validate({"report" => {
            "template" => "ad_events",
            "parameters" => {"start" => @datetime, "end" => @datetime}
          }}, :against => Report::SCHEMA.create)
        end

        it "should not approve a report with missing information" do
          invalidate({"report" => {
            "template" => "ad_events",
            "parameters" => {"start" => @datetime}
          }}, :against => Report::SCHEMA.create)
        end

        it "should not approve a report with extra information" do
          invalidate({"report" => {
            "template" => "ad_events",
            "parameters" => {"start" => @datetime, "end" => @datetime},
            "state" => "WAITING" #extra
          }}, :against => Report::SCHEMA.create)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Report::SCHEMA.create)
        end
      end

      describe "show" do
        it "should approve an example report" do
          validate({"report" => {
            "template" => "ad_events",
            "parameters" => {"start" => @datetime, "end" => @datetime},
            "state" => "RUNNING",
            "started_at" => @datetime,
            "finished_at" => nil,
            "accessed_at" => nil,
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => Report::SCHEMA.show)
        end

        it "should not approve a report with missing information" do
          invalidate({"report" => {
            "template" => "ad_events",
            "parameters" => {"start" => @datetime, "end" => @datetime},
            "state" => "RUNNING",
            "started_at" => @datetime,
            "finished_at" => nil,
            "accessed_at" => nil,
            # "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => Report::SCHEMA.show)
        end

        it "should not approve a report with extra information" do
          invalidate({"report" => {
            "template" => "ad_events",
            "parameters" => {"start" => @datetime, "end" => @datetime},
            "state" => "RUNNING",
            "started_at" => @datetime,
            "finished_at" => nil,
            "accessed_at" => nil,
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1,
            "name" => "extra"
          }}, :against => Report::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Report::SCHEMA.show)
        end
      end
    end
  end
end