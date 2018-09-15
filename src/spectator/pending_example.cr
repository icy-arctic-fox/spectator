require "./example"

module Spectator
  abstract class PendingExample < Example
    def run
      PendingExampleResult.new(self)
    end
  end
end
