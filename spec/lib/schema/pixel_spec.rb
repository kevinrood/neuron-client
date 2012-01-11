require 'json-schema'

module Neuron
  module Schema
    describe Pixel do
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
        it "should approve an example list of pixels" do
          validate(
            [{"pixel" => {"id" => 42}},
             {"pixel" => {"id" => 82}},
             {"pixel" => {"id" => 246}}
            ],
            :against => Pixel::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => Pixel::SCHEMA.index)
        end

        it "should not approve an example pixel outside of a list" do
          invalidate(
            {"pixel" => {"id" => 42}},
            :against => Pixel::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => Pixel::SCHEMA.index)
        end
      end

      describe "create" do
        it "should approve an example pixel" do
          validate({"pixel" => {
            "ad_ids" => []
          }}, :against => Pixel::SCHEMA.create)
        end

        it "should not approve a pixel with extra information" do
          invalidate({"pixel" => {
            "ad_ids" => [1,2,3],
            "name" => "extra"
          }}, :against => Pixel::SCHEMA.create)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Pixel::SCHEMA.create)
        end
      end

      describe "show" do
        it "should approve an example pixel" do
          validate({"pixel" => {
            "ad_ids" => [1,2,3],
            "id" => 1
          }}, :against => Pixel::SCHEMA.show)
        end

        it "should not approve a pixel with missing information" do
          invalidate({"pixel" => {
            "id" => 1
          }}, :against => Pixel::SCHEMA.show)
        end

        it "should not approve a pixel with extra information" do
          invalidate({"pixel" => {
            "ad_ids" => [1,2,3],
            "id" => 1,
            "name" => "extra"
          }}, :against => Pixel::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Pixel::SCHEMA.show)
        end
      end

      describe "update" do
        it "should approve an example pixel" do
          validate({"pixel" => {
            "ad_ids" => [1,2,3],
            "id" => 1
          }}, :against => Pixel::SCHEMA.update)
        end

        it "should not approve a pixel with missing information" do
          invalidate({"pixel" => {
            "id" => 1
          }}, :against => Pixel::SCHEMA.update)
        end

        it "should not approve a pixel with extra information" do
          invalidate({"pixel" => {
            "ad_ids" => [1,2,3],
            "id" => 1,
            "name" => "extra"
          }}, :against => Pixel::SCHEMA.update)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => Pixel::SCHEMA.update)
        end
      end
    end
  end
end