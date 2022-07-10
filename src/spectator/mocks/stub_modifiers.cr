module Spectator
  # Mixin intended for `Stub` to return new, modified stubs.
  module StubModifiers
    # Returns a new stub of the same type with constrained arguments.
    abstract def with(*args, **kwargs)
  end
end
