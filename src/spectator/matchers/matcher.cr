module Spectator
  module Matchers
    abstract class Matcher
      private getter label : String

      private def initialize(@label : String)
      end

      abstract def match?(expectation : Expectation)
      abstract def message(expectation : Expectation) : String
      abstract def negated_message(expectation : Expectation) : String
    end
  end
end
