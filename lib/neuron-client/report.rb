module Neuron
  module Client
    class Report
      include Connected
      resource_name("report")
      resources_name("reports")

      attr_accessor :errors
      attr_accessor :template, :parameters, :status

      def result
        self.class.connection.get("reports/#{id}/result")
      end
    end
  end
end