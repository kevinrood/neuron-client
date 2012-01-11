module Neuron
  module Schema
    class GeoTarget
      include Common

      SCHEMA = self.new

      def index
        @@index ||=
        set_of(object_type("geo_target",
          :id => id,
          :abbreviation => nonnull_string,
          :full_name => nonnull_string,
          :geo_type => choice_of(Neuron::Client::GeoTarget::TYPES),
          :name => nonnull_string,
          :netacuity_id => integer
        ))
      end

      def show
        @@show ||=
        object_type("geo_target",
          :id => id,
          :abbreviation => nonnull_string,
          :full_name => nonnull_string,
          :geo_type => choice_of(Neuron::Client::GeoTarget::TYPES),
          :name => nonnull_string,
          :netacuity_id => integer
        )
      end
    end
  end
end