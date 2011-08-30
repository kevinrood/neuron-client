module Neuron
  module Client
    describe MembaseConnection do
      describe "initialize(servers)" do
        it "should properly set @membase" do
          c = stub(:client)
          Dalli::Client.should_receive(:new).with('127.0.0.1:11211').and_return(c)

          m = MembaseConnection.new('127.0.0.1:11211')

          m.instance_variable_get(:@client).should == c
        end
      end

      describe "get(key)" do
        it "should call the expected method and return the expected value" do
          m = MembaseConnection.allocate
          c = stub(:client)
          m.instance_variable_set(:@client, c)
          c.should_receive(:get).with('key_value')

          m.get('key_value')
        end
      end
    end
  end
end