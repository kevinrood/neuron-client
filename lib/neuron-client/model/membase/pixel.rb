module Neuron
  module Client
    module Model
      module Membase
        class Pixel < Common::Pixel

          class << self
            def find(id)
              self.connection.local_cache.fetch("Neuron::Client::Model::Pixel:#{id}") do
                pixel = nil
                membase_key = "Pixel:#{id}"
                cached_json = self.connection.get(membase_key)
                pixel = self.new(Yajl.load(cached_json)[superclass.resource_name]) if cached_json.present?
                pixel
              end
            end
          end
        end
      end
    end
  end
end