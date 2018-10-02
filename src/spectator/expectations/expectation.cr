module Spectator::Expectations
  abstract class Expectation
    getter? negated : Bool

    private def initialize(@negated)
    end

    abstract def eval : Bool
    abstract def message : String
  end
end
