module Neuron
  module Client
    describe Pixel do
      context "when connected to the membase server" do
        before(:each) do
          @connection = stub(:connection)
          API.stub(:default_api).and_return(stub(:default_api, :connection => @connection, :connection_type => :membase, :validate? => true))
        end
        describe "Pixel.find(id)" do
          context "when the connection returns a value" do
            it "should call the expected methods and return the expected value" do
              p = stub(:pixel)
              attrs = {
                "id" => 7,
                "ad_ids" => []
              }
              @connection.stub_chain(:local_cache, :fetch).with('Pixel:7').and_yield.and_return(p)
              @connection.should_receive(:get).with('Pixel:7').and_return({'pixel' => attrs}.to_json)
              Pixel.should_receive(:new).with(attrs).and_return(p)

              Pixel.find(7).should == p
            end
          end
          context "when the connection returns nil" do
            it "should call the expected methods and return nil" do
              @connection.stub_chain(:local_cache, :fetch).with('Pixel:7').and_yield.and_return(nil)
              @connection.should_receive(:get).with('Pixel:7').and_return(nil)

              Pixel.find(7).should be_nil
            end
          end
        end
      end
    end
  end
end