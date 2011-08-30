module Neuron
  module Client
    describe API do
      describe "configure" do
        context "when connection_type is :admin" do
          it "should call the expected methods" do
            a = API.new
            c = stub(:config)
            a.should_receive(:config).exactly(4).times.and_return(c)
            c.should_receive(:connection_type=).with(:admin)
            a.should_receive(:inclusion).with(c, :connection_type, [:admin, :membase])
            c.should_receive(:connection_type).exactly(2).times.and_return(:admin)
            a.should_receive(:configure_admin_connection)

            a.configure do |conf|
              conf.connection_type = :admin
            end
          end
        end
        context "when connection_type is :membase" do
          it "should call the expected methods" do
            a = API.new
            c = stub(:config)
            a.should_receive(:config).exactly(4).times.and_return(c)
            c.should_receive(:connection_type=).with(:membase)
            a.should_receive(:inclusion).with(c, :connection_type, [:admin, :membase])
            c.should_receive(:connection_type).exactly(2).times.and_return(:membase)
            a.should_receive(:configure_membase_connection)

            a.configure do |conf|
              conf.connection_type = :membase
            end
          end
        end
      end

      describe "connection_type" do
        it "should return the expected value"
      end

      describe "config" do
        it "should return the expected value"
      end

      describe "required(obj, attrib)" do
        context "when val is nil" do
          it "should call the expected methods and raise an error"
        end
        context "when val is not nil and val.empty? does not exist" do
          it "should call the expected methods and not raise an error"
        end
        context "when val is not nil and val.empty? exists and returns true" do
          it "should call the expected methods and raise an error"
        end
      end

      describe "inclusion(obj, attrib, valid_values)" do
        context "when valid_values includes the attribute value" do
          it "should not raise an error"
        end
        context "when valid_values does not include the attribute value" do
          it "should raise an error"
        end
      end

      describe "configure_admin_connection" do
        context "when URI.parse raises an error" do
          it "should raise a custom error"
        end
        context "when URI.parse does not raise an error" do
          it "should call the expected methods"
        end
      end

      describe "configure_membase_connection" do
        it "should call the expected methods"
      end
    end
  end
end