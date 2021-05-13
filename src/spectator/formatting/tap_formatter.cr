require "./formatter"

module Spectator::Formatting
  class TAPFormatter < Formatter
    def pass(notification)
    end

    def fail(notification)
    end

    def pending(notification)
    end
  end
end
