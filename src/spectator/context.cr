require "../spectator_context"

module Spectator
  # Base class that all test cases run in.
  # This type is used to store all test case contexts as a single type.
  # The instance must be downcast to the correct type before calling a context method.
  alias Context = ::SpectatorContext
end
