module Spectator::Expectations
  class ExpectationResults
    def initialize(@results : Enumerable(ExpectationResult))
    end
  end
end
