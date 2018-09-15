require "./result"

module Spectator
  class PendingResult < Result
    def passed?
      false
    end

    def initialize(@example)
      super(@example, Time::Span.new(nanoseconds: 0))
    end
  end
end
