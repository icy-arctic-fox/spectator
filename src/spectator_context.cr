# Base class that all test cases run in.
# This type is used to store all test case contexts as a single type.
# The instance must be downcast to the correct type before calling a context method.
# This type is intentionally outside the `Spectator` module.
# The reason for this is to prevent name collision when using the DSL to define a spec.
abstract class SpectatorContext
end
