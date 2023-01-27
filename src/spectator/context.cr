# Base class that all test cases run in.
# This type is used to store all test case contexts as a single type.
# The instance must be downcast to the correct type before calling a context method.
# This type is intentionally outside the `Spectator` module.
# The reason for this is to prevent name collision when using the DSL to define a spec.
abstract class SpectatorContext
  # Evaluates the contents of a block within the scope of the context.
  def eval(&)
    with self yield
  end

  # Produces a dummy string to represent the context as a string.
  # This prevents the default behavior, which normally stringifies instance variables.
  # Due to the sheer amount of types Spectator can create
  # and that the Crystal compiler instantiates a `#to_s` and/or `#inspect` for each of those types,
  # an explosion in method instances can be created.
  # The compile time is drastically reduced by using a dummy string instead.
  def to_s(io : IO) : Nil
    io << "Context"
  end

  # :ditto:
  def inspect(io : IO) : Nil
    io << "Context<" << self.class << '>'
  end
end

module Spectator
  # Base class that all test cases run in.
  # This type is used to store all test case contexts as a single type.
  # The instance must be downcast to the correct type before calling a context method.
  #
  # Nested contexts, such as those defined by `context` and `describe` in the DSL, can define their own methods.
  # The intent is that a proc will downcast to the correct type and call one of those methods.
  # This is how methods that contain test cases, hooks, and other context-specific code blocks get invoked.
  alias Context = ::SpectatorContext
end
