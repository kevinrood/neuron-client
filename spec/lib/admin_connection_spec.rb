module Neuron
  module Client
    describe AdminConnection do
      describe "initialize(url, key)" do
        it "should set the appropriate instance variables"
      end

      describe "query_string(attrs={})" do
        it "should return the expected value"
      end

      describe "get(path="", attrs={})" do
        context "when response.code is 200" do
          context "when the format is :json" do
            it "should call the expected methods and return the expected value"
          end
        end
        context "when response.code is not 200" do
          it "it should raise an error"
        end
      end

      describe "post(path="", form={}, attrs={})" do
        context "when response.code is 201" do
          context "when the format is :json" do
            it "should call the expected methods and return the expected value"
          end
          context "when the format is not :json" do
            it "should call the expected methods and return the expected value"
          end
        end
        context "when response.code is 422" do
          context "when the format is :json" do
            it "should throw the expected symbol and object"
          end
          context "when the format is not :json" do
            it "should throw the expected symbol and object"
          end
        end
        context "when response.code is not 201 or 422" do
          it "should raise an error"
        end
      end

      describe "put(path="", form={}, attrs={})" do
        context "when response.code is 200" do
          context "when the format is :json" do
            it "should call the expected methods and return the expected value"
          end
          context "when the format is not :json" do
            it "should call the expected methods and return the expected value"
          end
        end
        context "when response.code is 422" do
          context "when the format is :json" do
            it "should throw the expected symbol and object"
          end
          context "when the format is not :json" do
            it "should throw the expected symbol and object"
          end
        end
        context "when response.code is not 200 or 422" do
          it "should raise an error"
        end
      end

      describe "delete(path="", attrs={})" do
        context "when response.code is 200" do
          context "when format is :json" do
            it "should call the expected methods and return the expected value"
          end
          context "when format is not :json" do
            it "should call the expected methods and return the expected value"
          end
        end
        context "when response.code is not 200" do
          it "should raise an error"
        end
      end
    end
  end
end