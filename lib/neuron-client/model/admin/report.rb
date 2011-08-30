module Neuron
  module Client
    module Model
      module Admin
        class Report < Common::Report
          include Base

          def result
            self.class.connection.get("reports/#{id}/result", :format => "")
          end
        end
      end
    end
  end
end