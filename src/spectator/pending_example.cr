require "./example"

module Spectator
  # Common class for all examples marked as pending.
  # This class will not run example code.
  abstract class PendingExample < Example
    # Returns a pending result.
    private def run_inner : Result
      PendingResult.new(self)
    end
  end
end
