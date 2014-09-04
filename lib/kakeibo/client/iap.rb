require 'uri'
require 'net/https'
require 'json'

require 'kakeibo/client/base'
require 'kakeibo/client/receipt/iap'

class Kakeibo
  class Client
    class Iap < Base
      PRODUCTION_ENDPOINT = "https://buy.itunes.apple.com/verifyReceipt"
      SANDBOX_ENDPOINT = "https://sandbox.itunes.apple.com/verifyReceipt"
      attr_reader :response

      def initialize
        @response = nil
      end

      def fetch(base64_encoded_data, option={})
        endpoint = PRODUCTION_ENDPOINT
        if option[:environment] == :sandbox
          endpoint = SANDBOX_ENDPOINT
        end

        parameters = {
          'receipt-data' => base64_encoded_data
        }
        parameters['password'] = option[:shared_secret] unless option[:shared_secret].nil?

        uri = URI(endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        request = Net::HTTP::Post.new(uri.request_uri)
        request['Accept'] = 'application/json'
        request['Content-Type'] = 'application/json'
        request.body = parameters.to_json
        @response = http.request(request)
        @response.value
        @response
      end

      def get_receipt
        Kakeibo::Client::Receipt::Iap.new(response.body)
      end
    end
  end
end
