module Spectator
  # Base class for proxying test values to examples.
  # This abstraction is required for inferring types.
  # The `DSL#let` macro makes heavy use of this.
  private abstract class ValueWrapper
    # Retrieves the underlying value.
    abstract def value
  end
end
