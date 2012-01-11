module Neuron
  module Client
    describe GeoTarget do
      context "when connected to the admin server" do
        describe "self.query(parameters)" do
          it "should call the expected methods and return the expected value" do
            c = stub(:connection)
            GeoTarget.should_receive(:connection).and_return(c)
            parameters = {:geo_type => 'COUNTRY', :search => 'USA', :limit => '10'}
            gta = {'id' => 1, 'abbreviation' => 'XYZ', 'full_name' => 'XYZ', 'name' => 'XYZ', 'geo_type' => 'METRO', 'netacuity_id' => 1}
            gta2 = gta.merge({'id' => 2})
            r = [
              {'geo_target' => gta},
              {'geo_target' => gta2}
            ]
            c.should_receive(:get).with('geo_targets', parameters).and_return(r)
            g = stub(:geo_target)
            g2 = stub(:geo_target2)
            GeoTarget.should_receive(:new).with(gta).and_return(g)
            GeoTarget.should_receive(:new).with(gta2).and_return(g2)

            GeoTarget.query(parameters).should == [g, g2]
          end
        end
      end
    end
  end
end