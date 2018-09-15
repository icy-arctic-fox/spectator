require "./example"

module Spectator
  abstract class PendingExample < Example
    def run
      PendingResult.new(self)
    end
  end
end
