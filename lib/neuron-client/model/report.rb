module Neuron
  module Client
    class Report
      include Base

      TEMPLATES = %w(ad_events delivery_metrics post_activities)

      STATES =  %w(NEW WAITING RUNNING READY FAILED CANCELLED)

      ATTRIBUTES = [
        :id,
        :parameters, # hash, where keys are parameter names, and values are parameter values as strings.
        :state,      # string, one of STATES
        :template,   # string, one of TEMPLATES
        :created_at, # string, datetime in UTC
        :updated_at, # string, datetime in UTC
      ]

      attr_accessor *ATTRIBUTES
      
      def attributes
        ATTRIBUTES
      end

      def status
        @state
      end

      def result
        connected_to_admin!
        connection.get("reports/#{id}/result", :format => "")
      end
    end
  end
end