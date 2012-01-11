require 'json-schema'

module Neuron
  module Schema
    describe AdZone do
      before(:each) do
        @datetime = "2011-11-11T11:11:11Z"
        @monkey_wrench = {"monkey_wrench" => {"id" => 42, "name" => "a", "updated_at" => @datetime}}
        @monkey_wrenches = [
          {"monkey_wrench" => {"id" => 1, "name" => "a", "updated_at" => @datetime}},
          {"monkey_wrench" => {"id" => 2, "name" => "b", "updated_at" => @datetime}},
          {"monkey_wrench" => {"id" => 3, "name" => "c", "updated_at" => @datetime}}
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
        it "should approve an example list of ad-zones" do
          validate(
            [{"ad_zone" => {"ad_id" => 42,  "zone_id" => "zone101", "weight" => 1.5, "priority" => 1}},
             {"ad_zone" => {"ad_id" => 82,  "zone_id" => "zone101", "weight" => 1.0, "priority" => 2}},
             {"ad_zone" => {"ad_id" => 246, "zone_id" => "zone102", "weight" => 1.5, "priority" => 1}}
            ],
            :against => AdZone::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => AdZone::SCHEMA.index)
        end

        it "should not approve an example ad_zone outside of a list" do
          invalidate(
            {"ad_zone" => {"ad_id" => 42,  "zone_id" => "zone101", "weight" => 1.5, "priority" => 1}},
            :against => AdZone::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => AdZone::SCHEMA.index)
        end
      end

      describe "create" do
        it "should approve an example ad-zone" do
          validate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
            "weight" => 1.0,
            "priority" => 1
          }}, :against => AdZone::SCHEMA.create)
        end

        it "should not approve a ad-zone with missing information" do
          invalidate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
          }}, :against => AdZone::SCHEMA.create)
        end

        it "should not approve a ad-zone with extra information" do
          invalidate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
            "weight" => 1.0,
            "priority" => 1,
            "id" => 9
          }}, :against => AdZone::SCHEMA.create)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => AdZone::SCHEMA.create)
        end
      end

      describe "show" do
        it "should approve an example ad-zone" do
          validate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
            "weight" => 1.0,
            "priority" => 1
          }}, :against => AdZone::SCHEMA.show)
        end

        it "should not approve a ad-zone with missing information" do
          invalidate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
          }}, :against => AdZone::SCHEMA.show)
        end

        it "should not approve a ad-zone with extra information" do
          invalidate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
            "weight" => 1.0,
            "priority" => 1,
            "id" => 9
          }}, :against => AdZone::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => AdZone::SCHEMA.show)
        end
      end

      describe "update" do
        it "should approve an example ad-zone" do
          validate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
            "weight" => 1.0,
            "priority" => 1
          }}, :against => AdZone::SCHEMA.update)
        end

        it "should not approve a ad-zone with missing information" do
          invalidate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
            "priority" => 1
          }}, :against => AdZone::SCHEMA.update)
        end

        it "should not approve a ad-zone with extra information" do
          invalidate({"ad_zone" => {
            "ad_id" => 1,
            "zone_id" => "zone1",
            "weight" => 1.0,
            "priority" => 1,
            "id" => 1
          }}, :against => AdZone::SCHEMA.update)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => AdZone::SCHEMA.update)
        end
      end
    end
  end
end