require "./result"

module Spectator
  class SuccessfulResult < Result
    def passed?
      true
    end

    def failed?
      false
    end

    def errored?
      false
    end

    def pending?
      false
    end
  end
end
