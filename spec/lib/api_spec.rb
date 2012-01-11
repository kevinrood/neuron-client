module Neuron
  module Client
    describe API do

      describe "configure" do
        it "creates a valid AdminConnection object" do
          api = API.new
          api.connection.should be_nil
          api.configure do |config|
            config.connection_type = :admin
            config.admin_url = "https://example.com"
            config.admin_key = "secret"
          end
          api.connection.should be_a(AdminConnection)
        end

        it "creates a valid MembaseConnection object" do
          api = API.new
          api.connection.should be_nil
          api.configure do |config|
            config.connection_type = :membase
            config.membase_servers = '127.0.0.1:11211'
            config.local_cache_size = 1000,
            config.local_cache_expires = 60
          end
          api.connection.should be_a(MembaseConnection)
        end

        it "raises an exception when given an admin_url that is not a URL" do
          api = API.new
          expect do
            api.configure do |config|
              config.connection_type = :admin
              config.admin_url = "not a url"
              config.admin_key = "secret"
            end
          end.to raise_exception
        end

        it "turns on validations by default" do
          api = API.new
          api.validate?.should be_true
          api.configure do |config|
            config.connection_type = :admin
            config.admin_url = "https://example.com"
            config.admin_key = "secret"
            config.validate = true
          end
          api.validate?.should be_true
          api.configure do |config|
            config.validate = false
          end
          api.validate?.should be_false
        end
      end
    end
  end
end