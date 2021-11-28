require "./dsl/*"

module Spectator
  # Namespace containing methods representing the spec domain specific language.
  #
  # Note: Documentation inside macros is kept to a minimum to reduce generated code.
  # This also helps keep error traces small.
  # Documentation only useful for debugging is included in generated code.
  module DSL
    # Keywords that cannot be used in specs using the DSL.
    # These are either problematic or reserved for internal use.
    RESERVED_KEYWORDS = %i[initialize]
  end
end
