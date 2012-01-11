require 'spec_helper'
require 'yajl'

module Neuron
  module Client
    describe S3File do
      context "when connected to the admin server" do
        before(:all) do
          API.default_api.configure do |config|
            config.connection_type = :admin
            config.admin_url = "http://127.0.0.1:3000"
            config.admin_key = "secret"
          end

          VCR.insert_cassette('s3_file', :record => :new_episodes)
        end

        after(:all) do
          VCR.eject_cassette
        end

        describe "create" do
          it "returns the created S3File" do
            attrs = {:bucket => 'test',
                     :filename => "filename",
                     :filesize => nil,
                     :purpose => 'RAW_EVENT_LOG'}
            s3file = S3File.create(attrs)
            s3file.id.should_not be_nil
            @@created_id = s3file.id
            s3file.bucket.should == attrs[:bucket]
            s3file.filename.should == attrs[:filename]
            s3file.purpose.should == attrs[:purpose]
          end
        end

        describe "all" do
          it "returns a list of S3Files" do
            s3files = S3File.all
            s3files.should be_a(Array)
            s3files.length.should be > 0
            s3files.first.should be_a(S3File)
          end
        end

        describe "find" do
          it "returns a S3File" do
            s3file = S3File.find(@@created_id)
            s3file.should be_a(S3File)
          end
        end

        describe "update_attributes" do
          it "updates the S3File on the server" do
            s3file = S3File.find(@@created_id)
            filename = s3file.filename
            s3file.update_attributes(:filename => "#{filename}_2")
            s3file = S3File.find(@@created_id)
            s3file.filename.should_not == filename
          end
        end
      end
    end
  end
end
