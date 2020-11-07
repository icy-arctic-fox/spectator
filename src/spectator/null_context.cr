module Spectator
  # Empty context used to construct examples that don't have contexts.
  # This is useful for dynamically creating examples outside of a spec.
  class NullContext < Context
  end
end
