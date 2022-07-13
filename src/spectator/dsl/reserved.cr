module Spectator
  module DSL
    # Keywords that cannot be used in specs using the DSL.
    # These are either problematic or reserved for internal use.
    RESERVED_KEYWORDS = %i[initialize finalize class allocate]
  end
end
