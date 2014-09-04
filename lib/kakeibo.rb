require 'kakeibo/error'
require 'kakeibo/client'

class Kakeibo
  attr_reader :receipt

  def initialize(platform, retry_count: 1, logger: nil)
    @platform     = platform     # :Iap or :Iab
    @retry_count  = retry_count
    @logger       = logger || Logger.new(STDOUT)
    @receipt = nil
  end

  # option
  # For IAP
  # :transaction_id -> SKPaymentTransaction#transactionIdentifier OPTIONAL
  # For IAB
  # :signature => included IAB response REQUIRED
  # :base64_encoded_public_key => license key REQUIRED
  # :developer_payload => developer payload OPTIONAL
  def fetch(data, option={})
    client   = ::Kakeibo::Client.new @platform
    count    = 0
    response = nil
    begin
      count += 1
      response = client.fetch(data, option)
    rescue => e
      @logger.error("ERROR #{e} #{e.message}")
      if count < @retry_count
        retry
      else
        raise e
      end
    end
    @receipt = client.get_receipt

    # IAP sandboxの場合の処理
    if @receipt.instance_of?(Kakeibo::Client::Receipt::Iap) && @receipt.status == Kakeibo::Client::Receipt::Iap::IS_SANDBOX_STATUS
      response = client.fetch(data, option.merge({environment: :sandbox}))
      @receipt = client.get_receipt
    end
    @receipt
  end

  def valid?
    return false if @receipt.nil?
    @receipt.valid?
  end

  def error
    return nil if @receipt.nil?
    @receipt.error
  end

end
