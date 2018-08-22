def expect(actual : T) forall T
  Spectator::Expectation.new(actual)
end

module Spectator
  class Expectation(T)
    getter actual : T

    protected def initialize(@actual : T)
    end
  end
end
