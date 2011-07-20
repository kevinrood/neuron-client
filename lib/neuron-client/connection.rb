require 'rest_client'
require 'yajl'

module Neuron
  module Client
    class Connection
      def initialize(url, key)
        @url = url
        @key = key
      end

      def query_string(attrs={})
        q = []
        {:api_key => @key}.merge(attrs).each do |key, value|
          q << "#{key}=#{CGI::escape(value)}"
        end
        q.join("&")
      end

      def get(path="", attrs={})
        RestClient.get("#{@url}/#{path}.json?#{query_string(attrs)}", :content_type => :json, :accept => :json) do |response, request, result, &block|
          case response.code
          when 200
            return Yajl.load(response.to_str)
          else
            raise "Error : #{response.code} - #{response.to_str}"
          end
        end
      end

      def post(path="", form={}, attrs={})
        RestClient.post("#{@url}/#{path}.json?#{query_string(attrs)}", Yajl.dump(form), :content_type => :json, :accept => :json) do |response, request, result, &block|
          case response.code
          when 201
            return Yajl.load(response.to_str)
          else
            raise "Error : #{response.code} - #{response.to_str}"
          end
        end
      end

      def put(path="", form={}, attrs={})
        RestClient.put("#{@url}/#{path}.json?#{query_string}", Yajl.dump(form), :content_type => :json, :accept => :json) do |response, request, result, &block|
          case response.code
          when 200
            return Yajl.load(response.to_str)
          else
            raise "Error : #{response.code} - #{response.to_str}"
          end
        end
      end

      def delete(path="", attrs={})
        RestClient.delete("#{@url}/#{path}.json?#{query_string(attrs)}", :content_type => :json, :accept => :json) do |response, request, result, &block|
          case response.code
          when 200
            return Yajl.load(response.to_str)
          else
            raise "Error : #{response.code} - #{response.to_str}"
          end
        end
      end
    end
  end
end
