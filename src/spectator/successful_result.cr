require "./finished_result"

module Spectator
  # Outcome that indicates running an example was successful.
  class SuccessfulResult < FinishedResult
    # Calls the `success` method on *interface* and passes self.
    def call(interface)
      interface.success(self)
    end
  end
end
