require "../matchers"

module Spectator
  module DSL
    module MatcherDSL
      macro eq(expected)
        ::Spectator::Matchers::EqualityMatcher.new({{expected.stringify}}, {{expected}})
      end
    end
  end
end
