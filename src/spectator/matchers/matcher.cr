module Spectator
  module Matchers
    abstract class Matcher
      private getter label : String

      private def initialize(@label : String)
      end

      abstract def match?(expectation : Expectation)
    end
  end
end
