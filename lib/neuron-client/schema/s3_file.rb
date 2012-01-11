module Neuron
  module Schema
    class S3File
      include Common

      SCHEMA = self.new

      def index
        @@index ||=
        set_of(object_type("s3_file", merged(CORE_PROPERTIES, SHOW_PROPERTIES)))
      end

      def create
        @@create ||=
        object_type("s3_file", CORE_PROPERTIES)
      end

      def show
        @@show ||=
        object_type("s3_file", merged(CORE_PROPERTIES, SHOW_PROPERTIES))
      end

      def update
        @@update ||=
        object_type("s3_file", {
          :id => id,
          :bucket => SCHEMA.bucket(:required => false),
          :filename => SCHEMA.filename(:required => false),
          :filesize => SCHEMA.filesize(:required => false),
          :purpose => SCHEMA.choice_of(Neuron::Client::S3File::PURPOSE_CHOICES, :required => false)
        })
      end

      # --------------------

      def bucket(overrides={})
        merged({
          :description => "The name of the Amazon S3 bucket",
          :type => "string",
          :pattern => "^[a-z\\d]([a-z\\d\\-]*[a-z\\d])?(\\.[a-z\\d]([a-z\\d\\-]*[a-z\\d])?)*$",
          :minLength => 3,
          :maxLength => 63,
          :required => true
        }, overrides)
      end

      def filename(overrides={})
        merged({
          :description => "The full name of the file within the Amazon S3 bucket",
          :type => "string",
          :minLength => 3,
          :maxLength => 255,
          :required => true
        }, overrides)
      end

      def filesize(overrides={})
        merged({
          :type => %w(integer string null),
          :required => true,
          :minimum => 1,
          :exclusiveMinimum => false,
          :pattern => "^[1-9]\\d*$"
        }, overrides)
      end

      # --------------------

      private

      CORE_PROPERTIES =
        {
          :bucket => SCHEMA.bucket,
          :filename => SCHEMA.filename,
          :filesize => SCHEMA.filesize,
          :purpose => SCHEMA.choice_of(Neuron::Client::S3File::PURPOSE_CHOICES)
        }

      SHOW_PROPERTIES =
        {
          :id => SCHEMA.id,
          :created_at => SCHEMA.datetime,
          :updated_at => SCHEMA.datetime
        }
    end
  end
end