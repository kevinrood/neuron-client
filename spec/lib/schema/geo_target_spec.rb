require 'json-schema'

module Neuron
  module Schema
    describe GeoTarget do
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
        it "should approve an example list of geo targets" do
          validate(
            [{"geo_target" => {"id" => 42,  "abbreviation" => "A",   "name" => "A", "full_name" => "A, Texas, USA", "geo_type" => "CITY", "netacuity_id" => 1}},
             {"geo_target" => {"id" => 82,  "abbreviation" => "TX",  "name" => "Texas", "full_name" => "Texas, USA", "geo_type" => "REGION", "netacuity_id" => 2}},
             {"geo_target" => {"id" => 246, "abbreviation" => "USA", "name" => "United States", "full_name" => "United States", "geo_type" => "COUNTRY", "netacuity_id" => 3}},
            ],
            :against => GeoTarget::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => GeoTarget::SCHEMA.index)
        end

        it "should not approve an example geo_target outside of a list" do
          invalidate(
            {"geo_target" => {"id" => 42,  "abbreviation" => "A",   "name" => "A", "full_name" => "A, Texas, USA", "geo_type" => "CITY", "netacuity_id" => 1}},
            :against => GeoTarget::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => GeoTarget::SCHEMA.index)
        end
      end

      describe "show" do
        it "should approve an example geo target" do
          validate({"geo_target" => {
            "id" => 42,
            "abbreviation" => "A",
            "name" => "A",
            "full_name" => "A, Texas, USA",
            "geo_type" => "CITY",
            "netacuity_id" => 1
          }}, :against => GeoTarget::SCHEMA.show)
        end

        it "should not approve a geo target with missing information" do
          invalidate({"geo_target" => {
            "id" => 42,
            "abbreviation" => "A",
            #"name" => "A",
            "full_name" => "A, Texas, USA",
            "geo_type" => "CITY",
            "netacuity_id" => 1
          }}, :against => GeoTarget::SCHEMA.show)
        end

        it "should not approve a geo target with extra information" do
          invalidate({"geo_target" => {
            "id" => 42,
            "abbreviation" => "A",
            "name" => "A",
            "full_name" => "A, Texas, USA",
            "geo_type" => "CITY",
            "netacuity_id" => 1,
            "extra" => "extra"
          }}, :against => GeoTarget::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => GeoTarget::SCHEMA.show)
        end
      end
    end
  end
end