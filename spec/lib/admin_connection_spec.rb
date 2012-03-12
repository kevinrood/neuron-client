module Neuron
  module Schema
    class TestModel
      SCHEMA = self.new
      def index; {}; end
      def show; {}; end
      def create; {} end
      def update; {} end
    end
  end
  module Client
    class TestModel
      include Base
      def attributes
        []
      end
    end

    describe AdminConnection do
      before(:each) do
        @connection = stub(:connection)
        API.stub(:default_api).and_return(stub(:default_api, :connection => @connection, :connection_type => :admin, :validate? => true))
      end
      
      describe "update_attributes" do
        it "should return false when errors occur for updated objects" do
          @connection.should_receive(:put).with("test_models/1", {'test_model' => {}}) do
            throw :errors, {:error => "is required"}
          end 

          TestModel.new(:id => 1).update_attributes({}).should be_false
        end

        it "should provide access to errors when validation fails" do
          @connection.should_receive(:put).with("test_models/1", {'test_model' => {}}) do
            throw :errors, {:error => "is required"}
          end 

          c = TestModel.new(:id => 1)
          c.update_attributes({}).should be_false
          c.errors.should == {:error => "is required"}
        end

        it "should return true when errors do not occur for updated objects" do
          @connection.should_receive(:put).with("test_models/1", {'test_model' => {}}).and_return({'test_model' => {}})

          TestModel.new(:id => 1).update_attributes({}).should be_true
        end
      end

      describe "save" do
        it "should return false when errors occur for new objects" do
          @connection.should_receive(:post).with("test_models", {'test_model' => {}}) do
            throw :errors, {:error => "is required"}
          end 

          TestModel.new.save.should be_false
        end

        it "should provide access to errors when validation fails" do
          @connection.should_receive(:post).with("test_models", {'test_model' => {}}) do
            throw :errors, {:error => "is required"}
          end 

          c = TestModel.new
          c.save.should be_false
          c.errors.should == {:error => "is required"}
        end

        it "should return true when errors do not occur for new objects" do
          @connection.should_receive(:post).with("test_models", {'test_model' => {}}).and_return({'test_model' => {:id => 1}})

          TestModel.new.save.should be_true
        end 

        it "should return false when errors occur for existing objects" do
          @connection.should_receive(:put).with('test_models/1', {'test_model' => {}}) do
            throw :errors, {:error => "is required"}
          end 

          TestModel.new(:id => 1).save.should be_false
        end

        it "should provide access to errors when validation fails" do
          @connection.should_receive(:put).with("test_models/1", {'test_model' => {}}) do
            throw :errors, {:error => "is required"}
          end 

          c = TestModel.new(:id => 1)
          c.save.should be_false
          c.errors.should == {:error => "is required"}
        end

        it "should return true when errors do not occur for existing objects" do
          @connection.should_receive(:put).with("test_models/1", {'test_model' => {}}).and_return({'test_model' => {:id => 1}})

          TestModel.new(:id => 1).save.should be_true
        end
      end

      describe "create" do
        it "should return object with errors when they occur" do
          @connection.should_receive(:post).with("test_models", {'test_model' => {}}) do
            throw :errors, {:error => "is_required"}
          end
          created = TestModel.create({})
          created.should be_a TestModel
          created.errors.should_not be_empty
          created.id.should be_nil
        end

        it "should return the created object when no errors occur" do
          @connection.should_receive(:post).with("test_models", {'test_model' => {}}).and_return({'test_model' => {:id => 1}})

          created = TestModel.create({})
          created.should be_a TestModel
          created.id.should == 1
        end
      end

      describe "create!" do
        it "should return nil when errors occur" do
          @connection.should_receive(:post).with("test_models", {'test_model' => {}}) do
            throw :errors, {:error => "is_required"}
          end

          errors = catch(:errors) do
            TestModel.create!({})
            nil
          end
          errors.should_not be_nil
          errors.should == {:error => 'is_required'}
        end

        it "should return the created object when no errors occur" do
          @connection.should_receive(:post).with("test_models", {'test_model' => {}}).and_return({'test_model' => {:id => 1}})

          TestModel.create!({}).should be_a TestModel
        end
      end
    end

    describe AdminConnection do
      before(:each) do
        @connection = AdminConnection.new('http://neuron.admin', "my_api_key")
      end

      it "should escape the passed api_key" do
        connection = AdminConnection.new("http://neuron.admin", "an unescaped string")
        FakeWeb.register_uri(:get, "http://neuron.admin/test.json?api_key=an+unescaped+string", :body => Yajl.dump({"escaped" => true}))
        connection.get("test").should == {"escaped" => true}
      end

      describe "get" do
        it "should make a GET request to the specified url passing an API key" do
          FakeWeb.register_uri(:get, "http://neuron.admin/test.json", :body => "ERROR", :status => ["403", "Unauthorized"])
          FakeWeb.register_uri(:get, "http://neuron.admin/test.json?api_key=my_api_key", :body => "{}")
          @connection.get("test").should == {}
        end

        it "should GET an error if the wrong api_key is passed" do
          FakeWeb.register_uri(:get, "http://neuron.admin/test.json?api_key=new_api_key", :body => "{}")
          FakeWeb.register_uri(:get, "http://neuron.admin/test.json?api_key=my_api_key", :body => "ERROR", :status => ["403", "Unauthorized"])
          lambda do
            @connection.get("test")
          end.should raise_error
        end
      end

      describe "post" do
        it "should make a POST request to the specified url passing an API key" do
          FakeWeb.register_uri(:post, "http://neuron.admin/test.json", :body => "ERROR", :status => ["403", "Unauthorized"])
          FakeWeb.register_uri(:post, "http://neuron.admin/test.json?api_key=my_api_key", :body => "{}", :status => ["201", "Created"])
          @connection.post("test", {:data => 1}).should == {}
        end

        it "should POST an error if the wrong api_key is passed" do
          FakeWeb.register_uri(:post, "http://neuron.admin/test.json?api_key=new_api_key", :body => "{}", :status => ["201", "Created"])
          FakeWeb.register_uri(:post, "http://neuron.admin/test.json?api_key=my_api_key", :body => "ERROR", :status => ["403", "Unauthorized"])
          lambda do 
            @connection.post("test", {:data => 1})
          end.should raise_error
        end

        it "should throw :errors if validation fails" do
          FakeWeb.register_uri(:post, "http://neuron.admin/test.json?api_key=my_api_key", :body => Yajl.dump({:my_field => 'is_required'}), :status => ["422", "Errors"])
          errors = catch(:errors) do
            value = @connection.post("test", {:data => 1})
            nil
          end
          errors.should_not be_nil
          errors.should == {'my_field' => 'is_required'}
        end
      end

      describe "put" do
        it "should make a PUT request to the specified url passing an API key" do
          FakeWeb.register_uri(:put, "http://neuron.admin/test.json", :body => "ERROR", :status => ["403", "Unauthorized"])
          FakeWeb.register_uri(:put, "http://neuron.admin/test.json?api_key=my_api_key", :body => "{}")
          @connection.put("test", {:data => 1}).should == {}
        end

        it "should PUT an error if the wrong api_key is passed" do
          FakeWeb.register_uri(:put, "http://neuron.admin/test.json?api_key=new_api_key", :body => "{}")
          FakeWeb.register_uri(:put, "http://neuron.admin/test.json?api_key=my_api_key", :body => "ERROR", :status => ["403", "Unauthorized"])
          lambda do
            @connection.put("test", {:data => 1})
          end.should raise_error
        end

        it "should throw :errors if validation fails" do
          FakeWeb.register_uri(:put, "http://neuron.admin/test.json?api_key=my_api_key", :body => Yajl.dump({:my_field => 'is_required'}), :status => ["422", "Errors"])
          errors = catch(:errors) do
            value = @connection.put("test", {:data => 1})
            nil
          end
          errors.should_not be_nil
          errors.should == {'my_field' => 'is_required'}
        end
      end

      describe "delete" do
        it "should make a DELETE request to the specified url passing an API key" do
          FakeWeb.register_uri(:delete, "http://neuron.admin/test.json", :body => "ERROR", :status => ["403", "Unauthorized"])
          FakeWeb.register_uri(:delete, "http://neuron.admin/test.json?api_key=my_api_key", :body => "{}")
          @connection.delete("test").should == {}
        end

        it "should DELETE an error if the wrong api_key is passed" do
          FakeWeb.register_uri(:delete, "http://neuron.admin/test.json?api_key=new_api_key", :body => "{}")
          FakeWeb.register_uri(:delete, "http://neuron.admin/test.json?api_key=my_api_key", :body => "ERROR", :status => ["403", "Unauthorized"])
          lambda do
            @connection.delete("test")
          end.should raise_error
        end
      end
    end



    describe AdminConnection do
      
      def stub_rest_client(receive, with_args, yield_args)
        expectation = RestClient.should_receive(receive).with(*with_args)
        if RUBY_VERSION =~ /^1\.8\./
          expectation.and_yield(yield_args)
        elsif RUBY_VERSION =~ /^1\.9\./
          expectation.and_yield(*yield_args)
        end
      end

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
          @ac.query_string(:foo=>'foo').split('&').sort.should == ["api_key=key","foo=foo"]
        end
      end

      describe "get(path="", attrs={})" do
        context "when response.code is 200" do
          context "when the format is :json" do
            it "should call the expected methods and return the expected value" do
              stub_rest_client(:get, ["url/json?api_key=key", {:content_type=>:json, :accept=>:json}], [@response, @request, @result])
              @ac.get().should == Yajl.load(@response.to_str)
            end
          end
        end
        context "when response.code is not 200" do
          it "it should raise an error" do
            @response.should_receive(:code).twice.and_return(500)
            stub_rest_client(:get,["url/json?api_key=key", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
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
              stub_rest_client(:post,["url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
              @ac.post().should == Yajl.load(@response.to_str)
            end
          end
          context "when the format is not :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(201)
              stub_rest_client(:post,["url/path.html?api_key=key", "{}", {:content_type=>:html, :accept=>:html}],[@response, @request, @result])
              @ac.post(:path, "{}", :format=>:html).should == @response.to_str
            end
          end
        end
        context "when response.code is 422" do
          context "when the format is :json" do
            it "should throw the expected symbol and object" do
              @response.should_receive(:code).and_return(422)
              stub_rest_client(:post, ["url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
              lambda{
                @ac.post()
              }.should raise_error
            end
          end
          context "when the format is not :json" do
            it "should throw the expected symbol and object" do
              @response.should_receive(:code).and_return(422)
              stub_rest_client(:post, ["url/path.html?api_key=key", "{}", {:content_type=>:html, :accept=>:html}],[@response, @request, @result])
              lambda{
                @ac.post(:path, "{}", :format=>:html)
              }.should raise_error
            end
          end
        end
        context "when response.code is not 201 or 422" do
          it "should raise an error" do
            @response.should_receive(:code).and_return(500)
            stub_rest_client(:post,["url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
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
              stub_rest_client(:put,["url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
              @ac.put().should == Yajl.load(@response.to_str)
            end
          end
          context "when the format is not :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(200)
              stub_rest_client(:put,["url/path.html?api_key=key", "{}", {:content_type=>:html, :accept=>:html}],[@response, @request, @result])
              @ac.put(:path, "{}", :format=>:html).should == @response.to_str
            end
          end
        end
        context "when response.code is 422" do
          context "when the format is :json" do
            it "should throw the expected symbol and object" do
              @response.should_receive(:code).and_return(422)
              stub_rest_client(:put,["url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
              lambda{
                @ac.put()
              }.should raise_error
            end
          end
          context "when the format is not :json" do
            it "should throw the expected symbol and object" do
              @response.should_receive(:code).and_return(422)
              stub_rest_client(:put,["url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
              lambda{
                @ac.put()
              }.should raise_error
            end
          end
        end
        context "when response.code is not 200 or 422" do
          it "should raise an error" do
            @response.should_receive(:code).and_return(500)
            stub_rest_client(:put,["url/json?api_key=key", "{}", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
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
              stub_rest_client(:delete,["url/path.json?api_key=key", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
              @ac.delete(:path).should == Yajl.load(@response.to_str)
            end
          end
          context "when format is not :json" do
            it "should call the expected methods and return the expected value" do
              @response.should_receive(:code).and_return(200)
              stub_rest_client(:delete,["url/path.html?api_key=key", {:content_type=>:html, :accept=>:html}],[@response, @request, @result])
              @ac.delete(:path, :format=>:html).should == @response.to_str
            end
          end
        end
        context "when response.code is not 200" do
          it "should raise an error" do
            @response.should_receive(:code).and_return(500)
            stub_rest_client(:delete,["url/json?api_key=key", {:content_type=>:json, :accept=>:json}],[@response, @request, @result])
            lambda{
              @ac.delete()
            }.should raise_error
          end
        end
      end
      
    end
  end
end