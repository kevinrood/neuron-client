module Neuron
  module Client
    module Model
      module Common
        class Report
          include Base

          resource_name("report")
          resources_name("reports")

          attr_accessor :errors
          attr_accessor :template, :parameters, :state

          def status
            @state
          end
        end
      end
    end
  end
end