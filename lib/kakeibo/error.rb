class Kakeibo
  class Error
    attr_reader :status
    attr_reader :message

    def initialize(status, message)
      @status = status
      @message = message
    end

  end
end
