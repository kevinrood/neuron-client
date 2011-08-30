module Neuron
  module Client
    module Model
      module Mock
        class BaseMockModel; end
      end

      class BaseMockModel < Base

      end

      describe Base do
        describe "instance methods" do
          describe "initialize(attrs=nil)" do
            it "should set @proxied_model appropriately" do
              pending "Not sure what the deal is here, it works outside of unit testing"

              ctp = stub(:class_to_proxy)
              Base.any_instance.should_receive(:class_to_proxy).and_return(ctp)
              p = stub(:proxy)
              ctp.should_receive(:new).with('attributes').and_return(p)
              b = Base.new('attributes')

              b.instance_variable_get(:@proxied_model).should == p
            end
          end

          describe "method_missing(meth, *args, &block)" do
            context "when method exists on the proxied model" do
              it "should call the method on the proxied model"
            end
            context "when method does not exist on the proxied model" do
              it "should call super.method_missing"
            end
          end
        end

        describe "class methods" do
          describe "api" do
            context "when @api exists" do
              it "should return the expected value" do
                a = stub(:api)
                Base.instance_variable_set(:@api, a)

                Base.api.should == a
              end
            end
            context "when @api does not exist" do
              it "should return the expected value" do
                Base.instance_variable_set(:@api, nil)
                a = stub(:default_api)
                Neuron::Client::API.should_receive(:default_api).and_return(a)

                Base.api.should == a
              end
            end
          end

          describe "connection" do
            it "should call the expected methods and return the expected result" do
              a = stub(:api)
              Base.should_receive(:api).and_return(a)
              c = stub(:connection)
              a.should_receive(:connection).and_return(c)

              Base.connection.should == c
            end
          end

          describe "class_to_proxy" do
            it "should call the expected methods and return the expected result" do
              BaseMockModel.stub_chain(:api, :connection_type).and_return(:mock)
              BaseMockModel.class_to_proxy.should == Neuron::Client::Model::Mock::BaseMockModel
            end
          end

          describe "method_missing(meth, *args, &block)" do
            context "when method exists on the class to proxy" do
              it "should call the method on the proxied model"
            end
            context "when method does not exist on the class to proxy" do
              it "should call super.method_missing"
            end
          end
        end
      end
    end
  end
end