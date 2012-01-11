require 'json-schema'

module Neuron
  module Schema
    describe BlockedUserAgent do
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
        it "should approve an example list of blocked user agents" do
          validate(
            [{"blocked_user_agent" => {"id" => 42, "description" => nil, "user_agent" => ".*robot.*"}},
             {"blocked_user_agent" => {"id" => 82, "description" => nil, "user_agent" => "^Badbot"}},
             {"blocked_user_agent" => {"id" => 246, "description" => nil, "user_agent" => "crawler$"}}
            ],
            :against => BlockedUserAgent::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => BlockedUserAgent::SCHEMA.index)
        end

        it "should not approve an example blocked user agent outside of a list" do
          invalidate(
            {"blocked_user_agent" => {"id" => 42, "description" => nil, "user_agent" => ".*robot.*"}},
            :against => BlockedUserAgent::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => BlockedUserAgent::SCHEMA.index)
        end
      end

      describe "create" do
        it "should approve an example blocked user agent" do
          validate({"blocked_user_agent" => {
            "description" => 'Anything with "robot" in it',
            "user_agent" => ".*robot.*"
          }}, :against => BlockedUserAgent::SCHEMA.create)
        end

        it "should not approve a blocked user agent with missing information" do
          invalidate({"blocked_user_agent" => {
            "description" => 'Anything with "robot" in it',
            #"user_agent" => ".*robot.*",
          }}, :against => BlockedUserAgent::SCHEMA.create)
        end

        it "should not approve a blocked user agent with extra information" do
          invalidate({"blocked_user_agent" => {
            "description" => 'Anything with "robot" in it',
            "user_agent" => ".*robot.*",
            "name" => "extra"
          }}, :against => BlockedUserAgent::SCHEMA.create)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => BlockedUserAgent::SCHEMA.create)
        end
      end

      describe "show" do
        it "should approve an example blocked user agent" do
          validate({"blocked_user_agent" => {
            "description" => 'Anything with "robot" in it',
            "user_agent" => ".*robot.*",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => BlockedUserAgent::SCHEMA.show)
        end

        it "should not approve a blocked user agent with missing information" do
          invalidate({"blocked_user_agent" => {
            "user_agent" => ".*robot.*",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => BlockedUserAgent::SCHEMA.show)
        end

        it "should not approve a blocked user agent with extra information" do
          invalidate({"blocked_user_agent" => {
            "description" => 'Anything with "robot" in it',
            "user_agent" => ".*robot.*",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1,
            "name" => "extra"
          }}, :against => BlockedUserAgent::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => BlockedUserAgent::SCHEMA.show)
        end
      end

      describe "update" do
        it "should approve an example blocked user agent" do
          validate({"blocked_user_agent" => {
            "description" => 'Anything with "robot" in it',
            "user_agent" => ".*robot.*",
            "id" => 1
          }}, :against => BlockedUserAgent::SCHEMA.update)
        end

        it "should not approve a blocked user agent with missing id" do
          invalidate({"blocked_user_agent" => {
            "description" => 'Anything with "robot" in it',
            "user_agent" => ".*robot.*",
            #"id" => 1
          }}, :against => BlockedUserAgent::SCHEMA.update)
        end

        it "should not approve a blocked user agent with extra information" do
          invalidate({"blocked_user_agent" => {
            "description" => 'Anything with "robot" in it',
            "user_agent" => ".*robot.*",
            "id" => 1,
            "name" => "extra"
          }}, :against => BlockedUserAgent::SCHEMA.update)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => BlockedUserAgent::SCHEMA.update)
        end
      end
    end
  end
end