# Base class that all test cases run in.
# This type is used to store all test case contexts as a single type.
# The instance must be downcast to the correct type before calling a context method.
# This type is intentionally outside the `Spectator` module.
# The reason for this is to prevent name collision when using the DSL to define a spec.
abstract class SpectatorContext
  # Initial implicit subject for tests.
  # This method should be overridden by example groups when an object is described.
  private def _spectator_implicit_subject
    nil
  end

  # Initial subject for tests.
  # Returns the implicit subject.
  # This method should be overridden when an explicit subject is defined by the DSL.
  # TODO: Subject needs to be cached.
  private def subject
    _spectator_implicit_subject
  end
end
