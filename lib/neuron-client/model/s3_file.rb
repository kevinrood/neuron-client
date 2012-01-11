module Neuron
  module Client
    class S3File
      include Base

      PURPOSE_CHOICES = [
        "REPORT_RESULT",
        "RAW_EVENT_LOG",
        "NORMALIZED_EVENT_LOG",
        "ENRICHED_EVENT_LOG"
      ]

      ATTRIBUTES = [
        :id,
        :bucket,     # string, at least 3 chars
        :filename,   # string
        :filesize,   # nil, or integer
        :purpose,    # string, one of PURPOSE_CHOICES
        :created_at, # string, datetime in UTC
        :updated_at, # string, datetime in UTC
      ]

      attr_accessor *ATTRIBUTES

      def attributes
        ATTRIBUTES
      end
    end
  end
end