module Spectator::Matchers
  abstract struct Matcher
    private getter label : String

    private def initialize(@label)
    end
  end
end
