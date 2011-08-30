module Neuron
  module Client
    module Model
      module Membase
        describe Zone do
          describe "Zone.all" do
            context "when connection.get returns a value" do
              it "should call the expected methods and return the expected result" do
                Zone.stub_chain(:connection, :get).with('Zone:7').and_return('{"zone":{"attr":"value","attr2":"value2"}}')
                z = stub(:zone)
                Zone.should_receive(:new).with({'attr' => 'value', 'attr2' => 'value2'}).and_return(z)

                Zone.find(7).should == z
              end
            end
            context "when connection.get returns nil" do
              it "should call the expected methods and return nil" do
                Zone.stub_chain(:connection, :get).with('Zone:7').and_return(nil)

                Zone.find(7).should be_nil
              end
            end
          end
        end
      end
    end
  end
end