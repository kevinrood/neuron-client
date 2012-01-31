module Neuron
  module Client
    describe Zone do
      before(:each) do
        @datetime = "2011-11-11T11:11:11Z"
        @minimal_attributes = {
          'ad_links'         => nil,
          'name'             => nil,
          'response_type'    => nil,
          'iris_version'     => nil,
          'template_slug'    => nil,
          'mute'             => nil,
          'autoplay'         => nil,
          'channel'          => nil,
          'expand'           => nil,
          'playlist_mode'    => nil,
          'volume'           => nil,
          'color'            => nil,
          'playback_mode'    => nil,
          'overlay_provider' => nil,
          'overlay_feed_url' => nil,
        }
      end
      context "when connected to the admin server" do
        before(:each) do
          @connection = stub(:connection)
          API.stub(:default_api).and_return(stub(:default_api, :connection => @connection, :connection_type => :admin, :validate? => true))
        end

        describe "all" do
          before(:each) do
            @response = [{'zone' => {'id' => 'zone1', 'name' => nil}}]
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
            @response = {'zone' => @minimal_attributes.merge(
              'id' => 'zone1',
              'name' => "Zone 1",
              'response_type' => 'Redirect',
              'ad_links' => {},
              'created_at' => @datetime,
              'updated_at' => @datetime
            )}
          end

          it "returns a Zone" do
            @connection.stub(:get).with("zones/zone1").and_return(@response)
            zone = Zone.find("zone1")
            zone.should be_a(Zone)
          end

          it "makes a get call" do
            @connection.should_receive(:get).with("zones/zone1").once.and_return(@response)
            Zone.find("zone1")
          end
        end

        describe "create" do
          before(:each) do
            @attrs = @minimal_attributes.merge(
              'name' => "Zone 1",
              'response_type' => 'Redirect',
              'ad_links' => {}
            )
            @response = {'zone' => @attrs.merge(
              'id' => "zone1",
              'created_at' => @datetime,
              'updated_at' => @datetime
            )}
          end

          it "posts json" do
            @connection.should_receive(:post).with("zones", {'zone' => @attrs}).once.and_return(@response)
            Zone.create(@attrs)
          end

          it "returns the created Ad" do
            @connection.should_receive(:post).and_return(@response)
            zone = Zone.create(@attrs)
            zone.id.should == "zone1"
            zone.name.should == "Zone 1"
          end
        end

        describe "update_attributes" do
          it "makes a put call" do
            attrs = @minimal_attributes.merge(
              'id' => 'zone1',
              'name' => 'Zone 1',
              'response_type' => 'Redirect',
              'ad_links' => {})
            zone = Zone.new(attrs)
            updated_attrs = attrs.merge('name' => 'Zone 2')
            @connection.should_receive(:put).with("zones/zone1", {'zone' => updated_attrs}).and_return({'zone' => updated_attrs})
            zone.update_attributes('name' => "Zone 2")
          end
        end

        describe "unlink(ad_id)" do
          it "should call the expected method and return the expected results" do
            zone = Zone.new(@minimal_attributes.merge('id' => 'z99'))
            @connection.should_receive(:delete).with('zones/z99/ads/7').and_return('return_value')

            zone.unlink(7).should == 'return_value'
          end
        end
      end
      context "when connected to the membase server" do
        before(:each) do
          @connection = stub(:connection)
          API.stub(:default_api).and_return(stub(:default_api, :connection => @connection, :connection_type => :membase, :validate? => true))
        end
        describe "Zone.find" do
          context "when connection.get returns a value" do
            it "should call the expected methods and return the expected result" do
              conn = MembaseConnection.new("example.com:11211")
              Zone.stub(:connection).and_return(conn)
              attrs = @minimal_attributes.merge(
                'id' => 'zone7',
                'response_type' => 'Redirect',
                'ad_links' => {},
                'created_at' => @datetime,
                'updated_at' => @datetime
              )
              conn.stub(:get).with('Zone:zone7').and_return({'zone' => attrs}.to_json)
              z = stub(:zone)
              Zone.should_receive(:new).with(attrs).and_return(z)

              Zone.find("zone7").should == z
            end
          end
          context "when connection.get returns nil" do
            it "should call the expected methods and return nil" do
              conn = MembaseConnection.new("example.com:11211")
              Zone.stub(:connection).and_return(conn)
              conn.stub(:get).with('Zone:zone7').and_return(nil)

              Zone.find("zone7").should be_nil
            end
          end
        end
      end

    end
  end
end
