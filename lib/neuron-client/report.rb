module Neuron
  module Client
    class Report
      include Connected
      resource_name("report")
      resources_name("reports")

      attr_accessor :errors
      attr_accessor :template, :parameters, :state

      def status
        @state
      end

      def result
        self.class.connection.get("reports/#{id}/result", :format => "")
      end
    end
  end
end