module Neuron
  module Client
    module Model
      module Admin
        describe Ad do
          describe "recent(statistic, parameters)" do
            it "should call the expecte method and return the expected result" do
              a = Ad.allocate
              c = stub(:connection)
              a.class.should_receive(:connection).and_return(c)
              a.should_receive(:id).and_return(7)
              p = stub(:parameters)
              c.should_receive(:get).with('ads/7/recent/statistic_value', p).and_return('return_value')

              a.recent('statistic_value', p).should == 'return_value'
            end
          end

          describe "unlink(ad_id)" do
            it "should call the expected method and return the expected result" do
              a = Ad.allocate
              c = stub(:connection)
              a.class.should_receive(:connection).and_return(c)
              a.should_receive(:id).and_return(7)
              c.should_receive(:delete).with('ads/7/zones/33').and_return('return_value')

              a.unlink(33).should == 'return_value'
            end
          end
        end
      end
    end
  end
end