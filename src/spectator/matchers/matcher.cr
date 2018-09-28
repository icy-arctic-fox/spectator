module Spectator::Matchers
  abstract class Matcher
    private getter label : String

    private def initialize(@label)
    end
  end
end
