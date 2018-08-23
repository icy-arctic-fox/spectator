module Spectator
  module Matchers
    abstract class Matcher
      abstract def match?(expectation : Expectation)
    end
  end
end
