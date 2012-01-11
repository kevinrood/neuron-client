module Neuron
  module Schema
    class Pixel
      include Common

      SCHEMA = self.new
      
      def index
        @@index ||=
        set_of(object_type("pixel",
          :id => id
        ))
      end

      def create
        @@create ||=
        object_type_or_null("pixel",
          :ad_ids => set_of(id, :required => false)
        )
      end

      def show
        @@show ||=
        object_type("pixel",
          :id => id,
          :ad_ids => set_of(id)
        )
      end

      def update
        @@update ||=
        object_type("pixel",
          :id => id,
          :ad_ids => set_of(id)
        )
      end
    end
  end
end