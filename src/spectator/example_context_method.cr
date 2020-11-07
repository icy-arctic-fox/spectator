require "./context"

module Spectator
  # Encapsulates a method in a test context.
  # This could be used to invoke a test case or hook method.
  # The context is passed as an argument.
  # The proc should downcast the context instance to the desired type and call a method on that context.
  # The current example is also passed as an argument.
  alias ExampleContextMethod = Example, Context ->
end
