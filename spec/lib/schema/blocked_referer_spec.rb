require 'json-schema'

module Neuron
  module Schema
    describe BlockedReferer do
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
        it "should approve an example list of blocked referers" do
          validate(
            [{"blocked_referer" => {"id" => 42, "referer" => "127.0.0.1"}},
             {"blocked_referer" => {"id" => 82, "referer" => "an.example.com"}},
             {"blocked_referer" => {"id" => 246, "referer" => "another.example.com/site/page.html"}}
            ],
            :against => BlockedReferer::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => BlockedReferer::SCHEMA.index)
        end

        it "should not approve an example blocked_referer outside of a list" do
          invalidate(
            {"blocked_referer" => {"id" => 42, "referer" => "127.0.0.1"}},
            :against => BlockedReferer::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => BlockedReferer::SCHEMA.index)
        end
      end

      describe "create" do
        it "should approve an example blocked referer" do
          validate({"blocked_referer" => {
            "referer" => "an.example.com"
          }}, :against => BlockedReferer::SCHEMA.create)
        end

        it "should not approve a blocked referer with missing information" do
          invalidate({"blocked_referer" => {
          }}, :against => BlockedReferer::SCHEMA.create)
        end

        it "should not approve a blocked referer with extra information" do
          invalidate({"blocked_referer" => {
            "referer" => "an.example.com",
            "name" => "extra"
          }}, :against => BlockedReferer::SCHEMA.create)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => BlockedReferer::SCHEMA.create)
        end
      end

      describe "show" do
        it "should approve an example blocked referer" do
          validate({"blocked_referer" => {
            "referer" => "an.example.com",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => BlockedReferer::SCHEMA.show)
        end

        it "should not approve a blocked referer with missing information" do
          invalidate({"blocked_referer" => {
            "referer" => "an.example.com",
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => BlockedReferer::SCHEMA.show)
        end

        it "should not approve a blocked referer with extra information" do
          invalidate({"blocked_referer" => {
            "referer" => "an.example.com",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1,
            "name" => "extra"
          }}, :against => BlockedReferer::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => BlockedReferer::SCHEMA.show)
        end
      end

      describe "update" do
        it "should approve an example blocked referer" do
          validate({"blocked_referer" => {
            "referer" => "an.example.com",
            "id" => 1
          }}, :against => BlockedReferer::SCHEMA.update)
        end

        it "should not approve a blocked referer with missing information" do
          invalidate({"blocked_referer" => {
            "id" => 1
          }}, :against => BlockedReferer::SCHEMA.update)
        end

        it "should not approve a blocked referer with extra information" do
          invalidate({"blocked_referer" => {
            "referer" => "an.example.com",
            "id" => 1,
            "name" => "extra"
          }}, :against => BlockedReferer::SCHEMA.update)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => BlockedReferer::SCHEMA.update)
        end
      end
    end
  end
end