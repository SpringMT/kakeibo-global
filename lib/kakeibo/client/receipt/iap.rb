require 'json'
require 'kakeibo/error'

class Kakeibo
  class Client
    class Receipt
      class Iap
        VALID_RECEIPT = 0
        INVALID_JSON = 1
        IS_SANDBOX_STATUS = 21007

        attr_reader :status
        attr_reader :receipt_data

        def initialize(raw_receipt_data, option={})
          @raw_receipt_data = raw_receipt_data
          @receipt_data     = nil
          @transaction_id   = option[:transaction_id]
          @status           = nil
          valid?
        end

        def valid?
          begin
            @receipt_data ||= JSON.parse(@raw_receipt_data, symbolize_names: true)
          rescue JSON::ParserError => e
            @status = INVALID_JSON
            return false
          end

          @status = @receipt_data[:status]
          return false if @status != VALID_RECEIPT
          return true if @transaction_id.nil?
          if ios7?(@receipt_data)
            @receipt_data[:receipt][:in_app].one? { |r| r[:transaction_id] == @transaction_id }
          else
            @receipt_data[:receipt][:transaction_id] == @transaction_id
          end
        end

        def error
          return nil if valid?
          Kakeibo::Error.new(@status, message)
        end

        private

        def ios7?(receipt_data)
          return false if receipt_data["receipt"].nil?
          receipt = receipt_data["receipt"]
          return false if receipt_data["in_app"].nil?
          true
        end

        def message
          case @status
          when INVALID_JSON
            "Receipt data is invalid json. #{@raw_receipt_data}"
          when 21000
            "The App Store could not read the JSON object you provided."
          when 21002
            "The data in the receipt-data property was malformed."
          when 21003
            "The receipt could not be authenticated."
          when 21004
            "The shared secret you provided does not match the shared secret on file for your account."
          when 21005
            "The receipt server is not currently available."
          when 21006
            "This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response."
          when 21007
            "This receipt is a sandbox receipt, but it was sent to the production service for verification."
          when 21008
            "This receipt is a production receipt, but it was sent to the sandbox service for verification."
          else
            "Unknown Error: #{@status}"
          end
        end

      end
    end
  end
end


