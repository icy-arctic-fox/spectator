require "./example_result"

module Spectator
  class PendingExampleResult < ExampleResult
    def passed?
      false
    end

    def initialize(@example)
      super(@example, Time::Span.new(nanoseconds: 0))
    end
  end
end
