require "../matchers"

module Spectator::DSL
  module MatcherDSL
    macro eq(expected)
      ::Spectator::Matchers::EqualityMatcher.new({{expected.stringify}}, {{expected}})
    end
  end
end
