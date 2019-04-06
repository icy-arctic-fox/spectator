module Spectator::Matchers
  # Abstract base for all match data values.
  # All sub-classes are expected to implement their own `#to_s`.
  private abstract class MatchDataValue
    # Placeholder for negating the value.
    def negate
      # ...
    end
  end
end
