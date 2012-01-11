module Neuron
  module Schema
    class AdZone
      include Common

      SCHEMA = self.new

      def index
        @@index ||=
        set_of(object_type("ad_zone",
          :ad_id => id,
          :zone_id => uuid,
          :weight => weight,
          :priority => priority
        ))
      end

      def create
        @@create ||=
        object_type("ad_zone",
          :ad_id => id,
          :zone_id => uuid,
          :weight => weight,
          :priority => priority
        )
      end

      def show
        @@show ||=
        object_type("ad_zone",
          :ad_id => id,
          :zone_id => uuid,
          :weight => weight,
          :priority => priority
        )
      end

      def update
        @@update ||=
        object_type("ad_zone",
          :ad_id => id,
          :zone_id => uuid,
          :weight => weight,
          :priority => priority
        )
      end
    end
  end
end