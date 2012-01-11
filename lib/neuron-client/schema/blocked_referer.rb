module Neuron
  module Schema
    class BlockedReferer
      include Common

      SCHEMA = self.new

      def index
        @@index ||=
        set_of(object_type("blocked_referer",
          :id => id,
          :referer => blocked_referer
        ))
      end

      def create
        @@create ||=
        object_type("blocked_referer",
          :referer => blocked_referer
        )
      end

      def show
        @@show ||=
        object_type("blocked_referer",
          :id => id,
          :referer => blocked_referer,
          :created_at => datetime,
          :updated_at => datetime
        )
      end

      def update
        @@update ||=
        object_type("blocked_referer",
          :id => id,
          :referer => blocked_referer
        )
      end

      private

      def blocked_referer(overrides={})
        merged({
          :type => "string",
          :maxLength => 2000,
          :required => true
        }, overrides)
      end
    end
  end
end