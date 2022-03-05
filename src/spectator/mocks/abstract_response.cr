module Spectator
  # Untyped response to a method call (message).
  abstract class AbstractResponse
    # Name of the method this response is for.
    getter method : Symbol

    # Creates the base of the response.
    def initialize(@method : Symbol)
    end
  end
end
