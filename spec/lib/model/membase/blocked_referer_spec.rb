module Neuron
  module Client
    module Model
      module Membase
        describe BlockedReferer do
          describe "BlockedReferer.all" do
            context "when connection returns a value" do
              it "should call the expected methods and return the expected value" do
                conn = MembaseConnection.new("example.com:11211")
                BlockedReferer.stub(:connection).and_return(conn)
                conn.stub(:get).with('blocked_referers').and_return('[{"blocked_referer":{"attr":"value"}},{"blocked_referer":{"attr2":"value2"}}]')
                br = stub(:blocked_referer)
                br2 = stub(:blocked_referer2)
                BlockedReferer.should_receive(:new).with({'attr' => 'value'}).and_return(br)
                BlockedReferer.should_receive(:new).with({'attr2' => 'value2'}).and_return(br2)

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
end