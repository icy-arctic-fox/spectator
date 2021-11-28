module Spectator
  # Identifier used in the spec.
  # Significant to the user.
  # When a label is a symbol, then it is referencing a type or method.
  # A label is nil when one can't be provided or captured.
  alias Label = String | Symbol | Nil
end
