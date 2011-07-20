require File.dirname(__FILE__) + '/../spec_helper'
require 'yajl'

module Neuron
  module Client

    describe API do
      describe "configure" do
        it "creates a valid Connection object" do
          API.reset!
          API.connection.should be_nil
          API.configure do |config|
            config.admin_url = "https://example.com"
            config.admin_key = "secret"
          end
          API.connection.should be_a(Connection)
        end
      end
    end

    describe AdZone do
      before(:each) do
        @connection = stub(:connection)
        API.stub(:connection).and_return(@connection)
      end
      describe "create" do
        it "makes a post call"
      end
    end

    describe Ad do
      before(:each) do
        @connection = stub(:connection)
        API.stub(:connection).and_return(@connection)
      end

      describe "all" do
        before(:each) do
          @response = [{}]
        end
        it "returns a list of Ads" do
          @connection.stub(:get).and_return(@response)
          ads = Ad.all
          ads.should be_a(Array)
          ads.length.should be > 0
          ads.first.should be_a(Ad)
        end

        it "makes a get call" do
          @connection.should_receive(:get).with("ads").once.and_return(@response)
          Ad.all
        end
      end

      describe "find" do
        before(:each) do
          @response = {:ad => {:id => 1, :name => "Ad 1"}}
        end

        it "returns a Ad" do
          @connection.stub(:get).and_return(@response)
          ad = Ad.find(1)
          ad.should be_a(Ad)
        end

        it "makes a get call" do
          @connection.should_receive(:get).with("ads/1").once.and_return(@response)
          Ad.find(1)
        end
      end

      describe "create" do
        before(:each) do
          @attrs = {:name => "Ad 1"}
          @response = {'ad' => @attrs.merge({:id => 1})}
        end

        it "posts json" do
          @connection.should_receive(:post).with("ads", {'ad' => @attrs}).once.and_return(@response)
          Ad.create(@attrs)
        end

        it "returns the created Ad" do
          @connection.should_receive(:post).and_return(@response)
          ad = Ad.create(@attrs)
          ad.id.should == 1
          ad.name.should == "Ad 1"
        end
      end

      describe "update_attributes" do
        it "makes a put call" do
          attrs = {:id => 1, :name => "Ad 1"}
          ad = Ad.new(attrs)
          @connection.should_receive(:put).with("ads/1", {'ad' => {:name => "Ad 2"}})
          ad.update_attributes(:name => "Ad 2")
        end
      end
    end

    describe Zone do
      before(:each) do
        @connection = stub(:connection)
        API.stub(:connection).and_return(@connection)
      end
      describe "all" do
        before(:each) do
          @response = [{}]
        end

        it "returns a list of Zones" do
          @connection.stub(:get).and_return(@response)
          zones = Zone.all
          zones.should be_a(Array)
          zones.length.should be > 0 
          zones.first.should be_a(Zone)
        end

        it "makes a get call" do
          @connection.should_receive(:get).with("zones").once.and_return(@response)
          Zone.all
        end
      end

      describe "find" do
        before(:each) do
          @response = {:zone => {:id => 1, :slug => "zone1"}}
        end

        it "returns a Zone" do
          @connection.stub(:get).and_return(@response)
          zone = Zone.find(1)
          zone.should be_a(Zone)
        end

        it "makes a get call" do
          @connection.should_receive(:get).with("zones/1").once.and_return(@response)
          Zone.find(1)
        end
      end

      describe "create" do
        before(:each) do
          @attrs = {:slug => "zone1"}
          @response = {'zone' => @attrs.merge({:id => 1})}
        end

        it "posts json" do
          @connection.should_receive(:post).with("zones", {'zone' => @attrs}).once.and_return(@response)
          Zone.create(@attrs)
        end

        it "returns the created Ad" do
          @connection.should_receive(:post).and_return(@response)
          zone = Zone.create(@attrs)
          zone.id.should == 1
          zone.slug.should == "zone1"
        end
      end

      describe "update_attributes" do
        it "makes a put call" do
          attrs = {:id => 1, :slug => "zone1"}
          zone = Zone.new(attrs)
          @connection.should_receive(:put).with("zones/1", {'zone' => {:slug => "zone2"}})
          zone.update_attributes(:slug => "zone2")
        end
      end
    end

    describe Connection do
      before(:each) do
        @connection = Connection.new('http://neuron.admin', "my_api_key")
      end

      it "should escape the passed api_key" do
        connection = Connection.new("http://neuron.admin", "an unescaped string")
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

  end
end
