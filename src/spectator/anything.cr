module Spectator
  # Equals and matches everything.
  # All comparison methods will always return true.
  struct Anything
    # Returns true for equality.
    def ==(_other)
      true
    end

    # Returns true for case equality.
    def ===(_other)
      true
    end

    # Returns true for matching.
    def =~(_other)
      true
    end
  end
end
