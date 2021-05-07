require "./reporter"

module Spectator::Reporters
  # Reports events to multiple other reporters.
  # Events received by this reporter will be sent to others.
  class BroadcastReporter < Reporter
    # Creates the broadcast reporter.
    # Takes a collection of reporters to pass events along to.
    def initialize(reporters : Enumerable(Reporter))
      @reporters = reporters.to_a
    end
  end
end
