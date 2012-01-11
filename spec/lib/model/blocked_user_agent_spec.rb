module Neuron
  module Client
    describe BlockedUserAgent do
      context "when connected to the membase server" do
        before(:each) do
          @connection = stub(:connection)
          API.stub(:default_api).and_return(stub(:default_api, :connection => @connection, :connection_type => :membase, :validate? => true))
        end
        describe "BlockedUserAgent.all" do
          context "when connection returns a value" do
            it "should call the expected methods and return the expected value" do
              conn = MembaseConnection.new("example.com:11211")
              BlockedUserAgent.stub(:connection).and_return(conn)
              conn.stub(:get).with('blocked_user_agents').and_return('[{"blocked_user_agent":{"id":42,"description":null,"user_agent":".*robot.*"}},{"blocked_user_agent":{"id":82,"description":null,"user_agent":"^Badbot"}}]')
              bua = stub(:blocked_user_agent)
              bua2 = stub(:blocked_user_agent2)
              BlockedUserAgent.should_receive(:new).with("id"=>42, "description"=>nil, "user_agent"=>".*robot.*").and_return(bua)
              BlockedUserAgent.should_receive(:new).with("id"=>82, "description"=>nil, "user_agent"=>"^Badbot").and_return(bua2)

              BlockedUserAgent.all.should == [bua, bua2]
            end
          end
          context "when connection returns nil" do
            it "should call the expected methods and return the expected value" do
              conn = MembaseConnection.new("example.com:11211")
              BlockedUserAgent.stub(:connection).and_return(conn)
              conn.stub(:get).with('blocked_user_agents').and_return(nil)

              BlockedUserAgent.all.should == []
            end
          end
        end
      end
    end
  end
end