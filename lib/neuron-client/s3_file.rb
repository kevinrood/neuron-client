module Neuron
  module Client
    class S3File
      include Base

      resource_name("s3_file")
      resources_name("s3_files")

      attr_accessor :bucket, :filename, :purpose, :created_at, :updated_at

    end
  end
end