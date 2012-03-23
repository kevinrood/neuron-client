require 'rest_client'
require 'yajl'

module Neuron
  module Client
    class AdminConnection
      def initialize(url, key)
        @url = url
        @key = key
      end

      def query_string(attrs={})
        q = []
        {:api_key => @key}.merge(attrs).each do |key, value|
          q << "#{key}=#{value.nil? ? '' : CGI::escape(value.to_s)}"
        end
        q.join("&")
      end

      def get(path="", attrs={})
        format = attrs.delete(:format) || :json
        RestClient.get("#{@url}/#{[path, format].select(&:present?).join(".")}?#{query_string(attrs)}",
          format.present? ? {:content_type => format, :accept => format} : {}) do |response, request, result, &block|
          # follow redirection
          if [301, 302, 307].include? response.code
            response.follow_redirection(request, result, &block)
          end

          case response.code
          when 200
            return (format == :json ? Yajl.load(response.to_str) : response.to_str)
          else
            raise "Error : #{response.inspect}"
          end
        end
      end

      def post(path="", form={}, attrs={})
        format = attrs.delete(:format) || :json
        RestClient.post("#{@url}/#{[path, format].select(&:present?).join(".")}?#{query_string(attrs)}",
          (format == :json ? Yajl.dump(form) : form),
          format.present? ? {:content_type => format, :accept => format} : {}) do |response, request, result, &block|
          case response.code
          when 201
            return (format == :json ? Yajl.load(response.to_str) : response.to_str)
          when 422
            throw :errors, format == :json ? Yajl.load(response.to_str) : response.to_str
          else
            raise "Error : #{response.code} - #{response.to_str}"
          end
        end
      end

      def put(path="", form={}, attrs={})
        format = attrs.delete(:format) || :json
        RestClient.put("#{@url}/#{[path, format].select(&:present?).join(".")}?#{query_string}",
          (format == :json ? Yajl.dump(form) : form),
          format.present? ? {:content_type => format, :accept => format} : {}) do |response, request, result, &block|
          case response.code
          when 200
            return (format == :json ? Yajl.load(response.to_str) : response.to_str)
          when 204
            return nil
          when 422
            throw :errors, format == :json ? Yajl.load(response.to_str) : response.to_str
          else
            raise "Error : #{response.code} - #{response.to_str}"
          end
        end
      end

      def delete(path="", attrs={})
        format = attrs.delete(:format) || :json
        RestClient.delete("#{@url}/#{[path, format].select(&:present?).join(".")}?#{query_string(attrs)}",
          format.present? ? {:content_type => format, :accept => format} : {}) do |response, request, result, &block|
          case response.code
          when 200
            return (format == :json ? Yajl.load(response.to_str) : response.to_str)
          else
            raise "Error : #{response.code} - #{response.to_str}"
          end
        end
      end
    end
  end
end
