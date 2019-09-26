module Spectator
  # Base class for proxying test values to examples.
  # This abstraction is required for inferring types.
  # The DSL makes heavy use of this to defer types.
  abstract class ValueWrapper
  end
end
