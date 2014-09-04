require 'json'
require 'kakeibo/error'

class Kakeibo
  class Client
    class Receipt
      class Iab
        VALID_RECEIPT = 0
        INVALID_JSON = 1
        SIGNATURE_IS_NIL = 2
        BASE64_ENCODED_PUBILC_KEY_IS_NIL = 3
        INVALID_SIGNATURE = 4
        INVALID_DEVELOPER_PAYLOAD = 5

        attr_reader :status
        attr_reader :order_id
        attr_reader :receipt_data

        def initialize(raw_receipt_data, option={})
          @raw_receipt_data = raw_receipt_data
          @receipt_data     = nil
          @signature                 = option[:signature]
          @base64_encoded_public_key = option[:base64_encoded_public_key]
          @developer_payload         = option[:developer_payload]

          @order_id = nil
          @status = nil
          valid?
        end

        def valid?
          begin
            @receipt_data ||= JSON.parse(@raw_receipt_data, symbolize_names: true)
          rescue JSON::ParserError => e
            @status = INVALID_JSON
            return false
          end

          @order_id = @receipt_data[:orderId]

          if @signature.nil?
            @status = SIGNATURE_IS_NIL
            return false
          end
          if @base64_encoded_public_key.nil?
            @status = BASE64_ENCODED_PUBILC_KEY_IS_NIL
            return false
          end

          public_key = OpenSSL::PKey::RSA.new(Base64.decode64(@base64_encoded_public_key))
          unless public_key.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(@signature), @raw_receipt_data)
            @status = INVALID_SIGNATURE
            return false
          end

          if !@receipt_data[:developerPayload].nil? && (@receipt_data[:developerPayload] != @developer_payload)
            @status = INVALID_DEVELOPER_PAYLOAD
            return false
          end

          @status = VALID_RECEIPT
          return true
        end

        def error
          return nil if valid?
          Kakeibo::Error.new(@status, message)
        end

        private

        def message
          case @status
          when INVALID_JSON
            "Receipt data is invalid json. #{@raw_receipt_data}"
          when SIGNATURE_IS_NIL
            "Option :signature is required at fetch."
          when BASE64_ENCODED_PUBILC_KEY_IS_NIL
            "Option :base64_encoded_public_key is required at fetch. Base64_encoded_public_key is license keys on a per-app. Please see youe Google Play account"
          when INVALID_SIGNATURE
            "Signature is invalid."
          when INVALID_DEVELOPER_PAYLOAD
            "Developer payload is invalid."
          else
            "Unknown Error: #{@status}"
          end
        end

      end
    end
  end
end


