module Neuron
  module Schema
    class Report
      include Common

      SCHEMA = self.new

      def index
        @@index ||=
        set_of(object_type("report",
          :id => id,
          :template => choice_of(Neuron::Client::Report::TEMPLATES),
          :state => choice_of(Neuron::Client::Report::STATES)
        ))
      end

      def create
        @@create ||=
        object_type("report",
          :template => choice_of(Neuron::Client::Report::TEMPLATES),
          :parameters => report_parameters
        )
      end

      def show
        @@show ||=
        object_type("report",
          :id => id,
          :template => choice_of(Neuron::Client::Report::TEMPLATES),
          :state => choice_of(Neuron::Client::Report::STATES),
          :parameters => report_parameters,
          :started_at =>  datetime(:type => %w(string null)),
          :finished_at => datetime(:type => %w(string null)),
          :accessed_at => datetime(:type => %w(string null)),
          :created_at =>  datetime,
          :updated_at =>  datetime
        )
      end

      private

      def report_parameters
        parameters({
          :start => datetime,
          :end => datetime
        }, {
          :patternProperties => {
            '^\\w{1,255}$' => {
              :type => "string",
              :required => true,
              :minLength => 1,
              :maxLength => 255
            }
          }
        })
      end
    end
  end
end