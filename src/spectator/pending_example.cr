require "./example"

module Spectator
  abstract class PendingExample < Example
    def run
      @finished = true
      PendingResult.new(self)
    end
  end
end
