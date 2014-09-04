require 'forwardable'

require 'kakeibo/client/iab'
require 'kakeibo/client/iap'

class Kakeibo
  # 各platformへの問い合わせを担う
  class Client
    extend Forwardable

    def initialize(platform)
      # iap iabのそれぞれのclientのインスタンスを返す
      constant = Object
      constant = constant.const_get 'Kakeibo'
      constant = constant.const_get 'Client'
      @client  = constant.const_get(platform, false).new
    end

    def_delegator :@client, :fetch, :fetch
    def_delegator :@client, :get_receipt, :get_receipt

  end
end


