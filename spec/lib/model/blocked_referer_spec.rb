module Neuron
  module Client
    describe BlockedReferer do
      context "when connected to the membase server" do
        before(:each) do
          @connection = stub(:connection)
          API.stub(:default_api).and_return(stub(:default_api, :connection => @connection, :connection_type => :membase, :validate? => true))
        end
        describe "BlockedReferer.all" do
          context "when connection returns a value" do
            it "should call the expected methods and return the expected value" do
              conn = MembaseConnection.new("example.com:11211")
              BlockedReferer.stub(:connection).and_return(conn)
              conn.stub(:get).with('blocked_referers').and_return('[{"blocked_referer":{"id": 42, "referer": "127.0.0.1"}}, {"blocked_referer":{"id": 82, "referer": "an.example.com"}}]')
              br = stub(:blocked_referer)
              br2 = stub(:blocked_referer2)
              BlockedReferer.should_receive(:new).with("id"=>42, "referer"=>"127.0.0.1").and_return(br)
              BlockedReferer.should_receive(:new).with("id"=>82, "referer"=>"an.example.com").and_return(br2)

              BlockedReferer.all.should == [br, br2]
            end
          end
          context "when connection returns nil" do
            it "should call the expected methods and return the expected value" do
              conn = MembaseConnection.new("example.com:11211")
              BlockedReferer.stub(:connection).and_return(conn)
              conn.stub(:get).with('blocked_referers').and_return(nil)

              BlockedReferer.all.should == []
            end
          end
        end
      end
    end
  end
end