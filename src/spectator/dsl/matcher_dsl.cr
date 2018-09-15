require "../matchers"

module Spectator
  module DSL
    module MatcherDSL
      def eq(expected : T) forall T
        ::Spectator::Matchers::EqualityMatcher(T).new(expected)
      end
    end
  end
end
