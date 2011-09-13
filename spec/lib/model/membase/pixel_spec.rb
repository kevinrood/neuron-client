module Neuron
  module Client
    module Model
      module Membase
        describe Pixel do
          describe "Pixel.find(id)" do
            context "when the connection returns a value" do
              it "should call the expected methods and return the expected value" do
                c = stub(:connection)
                Pixel.should_receive(:connection).exactly(2).times.and_return(c)
                p = stub(:pixel)
                c.stub_chain(:local_cache, :fetch).with('Neuron::Client::Model::Pixel:7').and_yield.and_return(p)
                c.should_receive(:get).with('Pixel:7').and_return('{"pixel":{"attr":"value","attr2":"value2"}}')
                Pixel.should_receive(:new).with({'attr' => 'value', 'attr2' => 'value2'}).and_return(p)

                Pixel.find(7).should == p
              end
            end
            context "when the connection returns nil" do
              it "should call the expected methods and return nil" do
                c = stub(:connection)
                Pixel.should_receive(:connection).exactly(2).times.and_return(c)
                c.stub_chain(:local_cache, :fetch).with('Neuron::Client::Model::Pixel:7').and_yield.and_return(nil)
                c.should_receive(:get).with('Pixel:7').and_return(nil)

                Pixel.find(7).should be_nil
              end
            end
          end
        end
      end
    end
  end
end