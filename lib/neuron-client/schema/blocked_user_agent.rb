module Neuron
  module Schema
    class BlockedUserAgent
      include Common

      SCHEMA = self.new
      
      def index
        @@index ||=
        set_of(object_type("blocked_user_agent",
          :id => id,
          :description => description,
          :user_agent => user_agent
        ))
      end

      def create
        @@create ||=
        object_type("blocked_user_agent",
          :description => description(:required => false),
          :user_agent => user_agent
        )
      end

      def show
        @@show ||=
        object_type("blocked_user_agent",
          :id => id,
          :description => description,
          :user_agent => user_agent,
          :created_at => datetime,
          :updated_at => datetime
        )
      end

      def update
        @@update ||=
        object_type("blocked_user_agent",
          :id => id,
          :description => description(:required => false),
          :user_agent => user_agent(:required => false)
        )
      end

      private

      def description(overrides={})
        merged({
          :type => %w(string null),
          :maxLength => 255,
          :required => true
        }, overrides)
      end

      def user_agent(overrides={})
        merged({
          :type => "string",
          :format => "regex",
          :required => true
        }, overrides)
      end
    end
  end
end