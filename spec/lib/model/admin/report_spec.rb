module Neuron
  module Client
    module Model
      module Admin
        describe Report do
          describe "result" do
            it "should call the expected methods and return the expected result" do
              r = Report.allocate
              c = stub(:connection)
              Report.should_receive(:connection).and_return(c)
              r.should_receive(:id).and_return(7)
              c.should_receive(:get).with('reports/7/result', :format => '').and_return('result_value')

              r.result.should == 'result_value'
            end
          end
        end
      end
    end
  end
end