module Neuron
  module Client
    module Model
      module Admin
        describe AdZone do
          describe "self.unlink(ad_id, zone_id)" do
            it "should call the expected method and return the expected value" do
              c = stub(:connection)
              AdZone.should_receive(:connection).and_return(c)
              c.should_receive(:delete).with('zones/1/ads/2').and_return('return_value')

              AdZone.unlink(2, 1).should == 'return_value'
            end
          end
        end
      end
    end
  end
end