module Spectator::Matchers
  # Abstract base for all match data values.
  # All sub-classes are expected to implement their own `#to_s`.
  private abstract class MatchDataValue
  end
end
