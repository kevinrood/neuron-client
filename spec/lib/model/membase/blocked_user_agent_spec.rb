module Neuron
  module Client
    module Model
      module Membase
        describe BlockedUserAgent do
          describe "BlockedUserAgent.all" do
            context "when connection returns a value" do
              it "should call the expected methods and return the expected value" do
                BlockedUserAgent.stub_chain(:connection, :get).with('blocked_user_agents').and_return('[{"blocked_user_agent":{"attr":"value"}},{"blocked_user_agent":{"attr2":"value2"}}]')
                bua = stub(:blocked_user_agent)
                bua2 = stub(:blocked_user_agent2)
                BlockedUserAgent.should_receive(:new).with({'attr' => 'value'}).and_return(bua)
                BlockedUserAgent.should_receive(:new).with({'attr2' => 'value2'}).and_return(bua2)

                BlockedUserAgent.all.should == [bua, bua2]
              end
            end
            context "when connection returns nil" do
              it "should call the expected methods and return the expected value" do
                BlockedUserAgent.stub_chain(:connection, :get).with('blocked_user_agents').and_return(nil)

                BlockedUserAgent.all.should == []
              end
            end
          end
        end
      end
    end
  end
end