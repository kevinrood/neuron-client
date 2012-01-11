module Neuron
  module Client
    describe AdZone do
      describe "self.unlink(ad_id, zone_id)" do
        it "should call the expected method and return the expected value" do
          c = stub(:connection)
          AdZone.stub(:connection).and_return(c)
          c.should_receive(:delete).with('zones/z1/ads/2').and_return('return_value')

          AdZone.unlink(2, "z1").should == 'return_value'
        end
      end
    end
  end
end