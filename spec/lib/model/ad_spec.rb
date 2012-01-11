module Neuron
  module Client
    describe Ad do
      before(:each) do
        @datetime = "2011-11-11T11:11:11Z"
        @minimal_attributes = {
          'acudeo_program_id'          => nil,
          'approved'                   => 'Yes',
          'clickthru_url'              => nil,
          'companion_ad_html'          => nil,
          'daily_cap'                  => nil,
          'day_partitions'             => nil,
          'end_datetime'               => nil,
          'frequency_cap'              => nil,
          'geo_target_netacuity_ids'   => {},
          'ideal_impressions_per_hour' => nil,
          'name'                       => nil,
          'overall_cap'                => nil,
          'pixel_ids'                  => [],
          'redirect_url'               => nil,
          'response_type'              => nil,
          'social_urls'                => nil,
          'start_datetime'             => @datetime,
          'time_zone'                  => "UTC",
          'vast_tracker_urls'          => nil,
          'vast_url'                   => nil,
          'video_flv_url'              => nil,
          'zone_links'                 => {},
        }
      end
      context "when connected to the admin server" do
        before(:each) do
          @connection = stub(:connection)
          API.stub(:default_api).and_return(stub(:default_api, :connection => @connection, :connection_type => :admin, :validate? => true))
        end

        describe "all" do
          before(:each) do
            @response = [{'ad' => {
              'id' => 1,
              'name' => nil
            }}]
          end
          it "returns a list of Ads" do
            @connection.stub(:get).with("ads").and_return(@response)
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
            @response = {'ad' => @minimal_attributes.merge(
              'id' => 1,
              'name' => "Ad 1",
              'response_type' => 'Redirect',
              'redirect_url' => 'http://example.com/',
              'created_at' => @datetime,
              'updated_at' => @datetime,
              'today_impressed' => 0,
              'total_impressed' => 0
            )}
          end

          it "returns a Ad" do
            @connection.stub(:get).with("ads/1").and_return(@response)
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
            @attrs = @minimal_attributes.merge(
              'name' => "Ad 1",
              'response_type' => 'VideoAd',
              'video_flv_url' => 'http://example.com/ad.flv',
              'clickthru_url' => 'http://example.com/buycrap',
              'companion_ad_html' => '<a href="http://example.com/">nana!</a>',
              'social_urls' => {},
              'vast_tracker_urls' => {}
            )
            @response = {'ad' => @attrs.merge({
              'id' => 1,
              'created_at' => @datetime,
              'updated_at' => @datetime,
              'total_impressed' => 0,
              'today_impressed' => 0
            })}
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

          it "returns the created Ad with vast_tracker_urls" do
            trackers = {"impression" => ["http://www.google.com"]}
            @attrs.merge!('vast_tracker_urls' => trackers)
            response = {'ad' => @attrs.merge({
              'id' => 1,
              'created_at' => @datetime,
              'updated_at' => @datetime,
              'total_impressed' => 0,
              'today_impressed' => 0
            })}
            @connection.should_receive(:post).and_return(response)
            ad = Ad.create(@attrs)
            ad.id.should == 1
            ad.vast_tracker_urls.should == trackers
          end
        end

        describe "update_attributes" do
          it "makes a put call" do
            attrs = @minimal_attributes.merge(
              'id' => 1,
              'name' => "Ad 1",
              'response_type' => 'Redirect',
              'redirect_url' => 'http://example.com'
            )
            ad = Ad.new(attrs)
            updated_attrs = attrs.merge('name' => 'Ad 2')
            @connection.should_receive(:put).with("ads/1", {'ad' => updated_attrs}).and_return({'ad' => updated_attrs.merge(
              'created_at' => @datetime,
              'updated_at' => @datetime,
              'total_impressed' => 0,
              'today_impressed' => 0
            )})
            ad.update_attributes('name' => "Ad 2")
          end

          it "makes a put call with vast_tracker_urls" do
            trackers = {'impression' => ["http://testurl.com"]}
            updated_trackers = {'impression' => ['http://testurl.com/new']}
            attrs = @minimal_attributes.merge(
              'id' => 1,
              'response_type' => 'VideoAd',
              'video_flv_url' => 'http://example.com/ad.flv',
              'clickthru_url' => 'http://example.com/buycrap',
              'companion_ad_html' => '<a href="http://example.com/">nana!</a>',
              'social_urls' => {},
              'vast_tracker_urls' => trackers
            )
            updated_attrs = attrs.merge('vast_tracker_urls' => updated_trackers)
            ad = Ad.new(attrs)
            @connection.should_receive(:put).with("ads/1", {'ad' => updated_attrs}).and_return({'ad' => updated_attrs.merge(
              'created_at' => @datetime,
              'updated_at' => @datetime,
              'total_impressed' => 0,
              'today_impressed' => 0              
            )})
            ad.update_attributes(updated_attrs)
          end
        end

        describe "recent(statistic, by=nil)" do
          it "should call the expected method and return the expected result" do
            ad = Ad.new(@minimal_attributes.merge('id' => 7))
            @connection.should_receive(:get).with('ads/7/recent/impressions', {'by' => 'zone'}).and_return('return_value')

            ad.recent('impressions', 'zone').should == 'return_value'
          end
        end

        describe "unlink(zone_id)" do
          it "should call the expected method and return the expected result" do
            ad = Ad.new(@minimal_attributes.merge('id' => 7))
            @connection.should_receive(:delete).with('ads/7/zones/z33').and_return('return_value')

            ad.unlink('z33').should == 'return_value'
          end
        end
      end

      context "when connected to the membase server" do
        before(:each) do
          @connection = stub(:connection)
          API.stub(:default_api).and_return(stub(:default_api, :connection => @connection, :connection_type => :membase, :validate? => true))
        end
        describe "total_impressed" do
          it "should call the expected methods and return the expected value" do
            ad = Ad.new(@minimal_attributes.merge('id' => 7))
            @connection.stub(:get).with('count_delivery_ad_7',1).and_return('999.999')

            ad.total_impressed.should == 999.999
          end
        end

        describe "today_impressed" do
          it "should call the expected methods and return the expected value" do
            ad = Ad.new(@minimal_attributes.merge('id' => 7, 'time_zone' => 'time_zone_value'))
            Time.stub_chain(:now, :in_time_zone).with('time_zone_value').and_return(Time.parse("2011-05-06 07:08"))
            @connection.stub(:get).with('count_delivery_20110506_ad_7',1).and_return('99.99')

            ad.today_impressed.should == 99.99
          end
        end

        describe "Ad.find(id)" do
          context "when the connection returns a value" do
            it "should call the expected methods and return the expected value" do
              connection = MembaseConnection.new("example.com:11211")
              Ad.stub(:connection).and_return(connection)
              attrs = @minimal_attributes.merge(
                'id' => 7,
                'response_type' => 'Redirect',
                'redirect_url' => 'http://example.com/',
                'created_at' => @datetime,
                'updated_at' => @datetime,
                'total_impressed' => 0,
                'today_impressed' => 0
              )
              connection.stub(:get).with('Ad:7').and_return({'ad' => attrs}.to_json)
              a = stub(:ad)
              Ad.should_receive(:new).with(attrs).and_return(a)

              Ad.find(7).should == a
            end
          end
          context "when the connection returns nil" do
            it "should call the expected methods and return nil" do
              connection = MembaseConnection.new("example.com:11211")
              Ad.stub(:connection).and_return(connection)
              connection.stub(:get).with('Ad:7').and_return(nil)

              Ad.find(7).should be_nil
            end
          end
        end
      end
    end
  end
end