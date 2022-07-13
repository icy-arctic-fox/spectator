module Spectator
  # Defines the name of a double or mock.
  #
  # When present on a stubbed type, this annotation indicates its name in output such as exceptions.
  # Must have one argument - the name of the double or mock.
  # This can be a symbol, string literal, or type name.
  annotation StubbedName
  end
end
