module Neuron
  module Client
    module Admin
      module Report

        def result
          self.class.admin_connection.get("reports/#{id}/result", :format => "")
        end

      end
    end
  end
end