require 'kakeibo/client/base'
require 'kakeibo/client/receipt/iab'

class Kakeibo
  class Client
    class Iab < Base
      def initialize(environment: :production)
        @raw_data = nil
        @option = nil
      end

      def fetch(raw_data, option={})
        @raw_data = raw_data
        @option = option
        true
      end

      def get_receipt
        Kakeibo::Client::Receipt::Iab.new(@raw_data, @option)
      end
    end
  end
end

