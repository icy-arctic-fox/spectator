require "./formatter"

module Spectator::Formatting
  # Reports events to multiple other formatters.
  # Events received by this formatter will be sent to others.
  class BroadcastFormatter < Formatter
    # Creates the broadcast formatter.
    # Takes a collection of formatters to pass events along to.
    def initialize(@formatters : Enumerable(Formatter))
    end
  end
end
