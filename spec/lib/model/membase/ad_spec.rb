module Neuron
  module Client
    module Model
      module Membase
        describe Ad do
          describe "total_impressed" do
            it "should call the expected methods and return the expected value" do
              a = Ad.allocate
              a.should_receive(:id).and_return(7)
              Ad.stub_chain(:connection, :get).with('count_delivery_ad_7').and_return('999.999')

              a.total_impressed.should == 999.999
            end
          end

          describe "today_impressed" do
            it "should call the expected methods and return the expected value" do
              a = Ad.allocate
              a.should_receive(:time_zone).and_return('time_zone_value')
              Time.stub_chain(:now, :in_time_zone).with('time_zone_value').and_return(Time.new(2011, 5, 6, 7, 8, 9))
              a.should_receive(:id).and_return(7)
              Ad.stub_chain(:connection, :get).with('count_delivery_20110506_ad_7').and_return('99.99')

              a.today_impressed.should == 99.99
            end
          end

          describe "Ad.find(id)" do
            context "when the connection returns a value" do
              it "should call the expected methods and return the expected value" do
                Ad.stub_chain(:connection, :get).with('Ad:7').and_return('{"ad":{"attr":"value","attr2":"value2"}}')
                a = stub(:ad)
                Ad.should_receive(:new).with({'attr' => 'value', 'attr2' => 'value2'}).and_return(a)

                Ad.find(7).should == a
              end
            end
            context "when the connection returns nil" do
              it "should call the expected methods and return nil" do
                Ad.stub_chain(:connection, :get).with('Ad:7').and_return(nil)

                Ad.find(7).should be_nil
              end
            end
          end
        end
      end
    end
  end
end