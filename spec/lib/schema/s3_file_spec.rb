require 'json-schema'

module Neuron
  module Schema
    describe S3File do
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
        it "should approve an example list of S3 files" do
          validate(
            [{"s3_file" => {"id" => 42,  "bucket" => "abc", "filename" => "1.log", "filesize" => 123, "purpose" => "RAW_EVENT_LOG", "created_at" => @datetime, "updated_at" => @datetime}},
             {"s3_file" => {"id" => 82,  "bucket" => "abc", "filename" => "2.log", "filesize" => 123, "purpose" => "RAW_EVENT_LOG", "created_at" => @datetime, "updated_at" => @datetime}},
             {"s3_file" => {"id" => 246, "bucket" => "abc", "filename" => "3.log", "filesize" => 123, "purpose" => "RAW_EVENT_LOG", "created_at" => @datetime, "updated_at" => @datetime}},
            ],
            :against => S3File::SCHEMA.index)
        end

        it "should approve an empty list" do
          validate([], :against => S3File::SCHEMA.index)
        end

        it "should not approve an example S3 file outside of a list" do
          invalidate(
            {"s3_file" => {"id" => 42,  "bucket" => "abc", "filename" => "1.log", "filesize" => 123, "purpose" => "RAW_EVENT_LOG", "created_at" => @datetime, "updated_at" => @datetime}},
            :against => S3File::SCHEMA.index)
        end

        it "should not approve an example list of monkey wrenches" do
          invalidate(@monkey_wrenches, :against => S3File::SCHEMA.index)
        end
      end

      describe "create" do
        it "should approve an example S3 file" do
          validate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "filesize" => nil,
            "purpose" => "RAW_EVENT_LOG",
          }}, :against => S3File::SCHEMA.create)
        end

        it "should not approve a S3 file with missing information" do
          invalidate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "purpose" => "RAW_EVENT_LOG",
          }}, :against => S3File::SCHEMA.create)
        end

        it "should not approve a S3 file with extra information" do
          invalidate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "filesize" => nil,
            "purpose" => "RAW_EVENT_LOG",
            "name" => "extra"
          }}, :against => S3File::SCHEMA.create)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => S3File::SCHEMA.create)
        end
      end

      describe "show" do
        it "should approve an example S3 file" do
          validate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "filesize" => nil,
            "purpose" => "RAW_EVENT_LOG",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => S3File::SCHEMA.show)
        end

        it "should not approve a S3 file with missing information" do
          invalidate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "purpose" => "RAW_EVENT_LOG",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1
          }}, :against => S3File::SCHEMA.show)
        end

        it "should not approve a S3 file with extra information" do
          invalidate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "filesize" => nil,
            "purpose" => "RAW_EVENT_LOG",
            "created_at" => @datetime,
            "updated_at" => @datetime,
            "id" => 1,
            "name" => "extra"
          }}, :against => S3File::SCHEMA.show)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => S3File::SCHEMA.show)
        end
      end

      describe "update" do
        it "should approve an example S3 file" do
          validate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "filesize" => 1234,
            "purpose" => "RAW_EVENT_LOG",
            "id" => 1
          }}, :against => S3File::SCHEMA.update)
        end

        it "should not approve a S3 file with missing id" do
          invalidate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "filesize" => 1234,
            "purpose" => "RAW_EVENT_LOG",
            #"id" => 1
          }}, :against => S3File::SCHEMA.update)
        end

        it "should not approve a S3 file with extra information" do
          invalidate({"s3_file" => {
            "bucket" => "abc",
            "filename" => "1.log",
            "filesize" => nil,
            "purpose" => "RAW_EVENT_LOG",
            "id" => 1,
            "name" => "extra"
          }}, :against => S3File::SCHEMA.update)
        end

        it "should not approve a monkey wrench" do
          invalidate(@monkey_wrench, :against => S3File::SCHEMA.update)
        end
      end
    end
  end
end