module Neuron
  module Client
    module Model
      module Admin
        describe GeoTarget do
          describe "self.query(parameters)" do
            it "should call the expected methods and return the expected value" do
              c = stub(:connection)
              GeoTarget.should_receive(:connection).and_return(c)
              p = stub(:parameters)
              gta = stub(:geo_target_attributes)
              gta2 = stub(:geo_target_attributes)
              r = [
                {'geo_target' => gta},
                {'geo_target' => gta2}
              ]
              c.should_receive(:get).with('geo_targets', p).and_return(r)
              g = stub(:geo_target)
              g2 = stub(:geo_target2)
              GeoTarget.should_receive(:new).with(gta).and_return(g)
              GeoTarget.should_receive(:new).with(gta2).and_return(g2)

              GeoTarget.query(p).should == [g, g2]
            end
          end
        end
      end
    end
  end
end