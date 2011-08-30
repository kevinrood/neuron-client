module Neuron
  module Client
    module Model
      module Admin
        describe Zone do
          describe "unlink(ad_id)" do
            it "should call the expected method and return the expected results" do
              z = Zone.allocate
              c = stub(:connection)
              Zone.should_receive(:connection).and_return(c)
              z.should_receive(:id).and_return(1)
              c.should_receive(:delete).with('zones/1/ads/2').and_return('result_value')

              z.unlink(2).should == 'result_value'
            end
          end
        end
      end
    end
  end
end