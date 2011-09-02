module Neuron
  module Client
    describe AdminConnection do
      before(:each) do
        @ac = AdminConnection.new('url', 'key')
        @response = mock(:response, :code=>200, :to_str=>"{}")
        @request = mock(:request)
        @result = mock(:result)
      end

      describe "initialize(url, key)" do
        it "should set the appropriate instance variables" do
          @ac.class.should == Neuron::Client::AdminConnection
        end
      end

      describe "query_string(attrs={})" do
        it "should return the expected value" do
          @ac.query_string({}).should == "api_key=key"
          @ac.query_string(:foo=>'foo').should == "api_key=key&foo=foo"
        end
      end

      describe "get(path="", attrs={})" do
        context "when response.code is 200" do
          context "when the format is :json" do
            it "should call the expected methods and return the expected value" do
              RestClient.should_receive(:get).with("url/json?api_key=key", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
              @ac.get().should == Yajl.load(@response.to_str)
            end
          end
        end
        context "when response.code is not 200" do
          it "it should raise an error" do
            @response.should_receive(:code).twice.and_return(500)
            RestClient.should_receive(:get).with("url/json?api_key=key", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
            lambda{
              @ac.get()              
            }.should raise_error
          end
        end
      end

      describe "post(path="", form={}, attrs={})" do
        context "when response.code is 201" do
          context "when the format is :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(201)
              RestClient.should_receive(:post).with("url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
              @ac.post().should == Yajl.load(@response.to_str)
            end
          end
          context "when the format is not :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(201)
              RestClient.should_receive(:post).with("url/path.html?api_key=key", "{}", {:content_type=>:html, :accept=>:html}).and_yield(@response, @request, @result)
              @ac.post(:path, "{}", :format=>:html).should == @response.to_str
            end
          end
        end
        context "when response.code is 422" do
          context "when the format is :json" do
            it "should throw the expected symbol and object" do
              @response.should_receive(:code).and_return(422)
              RestClient.should_receive(:post).with("url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
              lambda{
                @ac.post()
              }.should raise_error
            end
          end
          context "when the format is not :json" do
            it "should throw the expected symbol and object" do
              @response.should_receive(:code).and_return(422)
              RestClient.should_receive(:post).with("url/path.html?api_key=key", "{}", {:content_type=>:html, :accept=>:html}).and_yield(@response, @request, @result)
              lambda{
                @ac.post(:path, "{}", :format=>:html)
              }.should raise_error
            end
          end
        end
        context "when response.code is not 201 or 422" do
          it "should raise an error" do
            @response.should_receive(:code).and_return(500)
            RestClient.should_receive(:post).with("url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
            lambda{
              @ac.post()
            }.should raise_error
          end
        end
      end
      
      describe "put(path="", form={}, attrs={})" do
        context "when response.code is 200" do
          context "when the format is :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(200)
              RestClient.should_receive(:put).with("url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
              @ac.put().should == Yajl.load(@response.to_str)
            end
          end
          context "when the format is not :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(200)
              RestClient.should_receive(:put).with("url/path.html?api_key=key", "{}", {:content_type=>:html, :accept=>:html}).and_yield(@response, @request, @result)
              @ac.put(:path, "{}", :format=>:html).should == @response.to_str
            end
          end
        end
        context "when response.code is 422" do
          context "when the format is :json" do
            it "should throw the expected symbol and object" do
              @response.should_receive(:code).and_return(422)
              RestClient.should_receive(:put).with("url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
              lambda{
                @ac.put()
              }.should raise_error
            end
          end
          context "when the format is not :json" do
            it "should throw the expected symbol and object" do
              @response.should_receive(:code).and_return(422)
              RestClient.should_receive(:put).with("url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
              lambda{
                @ac.put()
              }.should raise_error
            end
          end
        end
        context "when response.code is not 200 or 422" do
          it "should raise an error" do
            @response.should_receive(:code).and_return(500)
            RestClient.should_receive(:put).with("url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
            lambda{
              @ac.put()
            }.should raise_error
          end
        end
      end
      
      describe "delete(path="", attrs={})" do
        context "when response.code is 200" do
          context "when format is :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(200)
              RestClient.should_receive(:delete).with("url/path.json?api_key=key", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
              @ac.delete(:path).should == Yajl.load(@response.to_str)
            end
          end
          context "when format is not :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(200)
              RestClient.should_receive(:delete).with("url/path.html?api_key=key", {:content_type=>:html, :accept=>:html}).and_yield(@response, @request, @result)
              @ac.delete(:path, :format=>:html).should == @response.to_str
            end
          end
        end
        context "when response.code is not 200" do
          it "should raise an error" do
            @response.should_receive(:code).and_return(500)
            RestClient.should_receive(:delete).with("url/json?api_key=key", {:content_type=>:json, :accept=>:json}).and_yield(@response, @request, @result)
            lambda{
              @ac.delete()
            }.should raise_error
          end
        end
      end
      
    end
  end
end