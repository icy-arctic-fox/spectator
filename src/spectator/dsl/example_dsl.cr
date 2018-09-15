require "./matcher_dsl"

module Spectator
  module DSL
    module ExampleDSL
      include MatcherDSL

      macro is_expected
        expect(subject)
      end

      def expect(actual : T) forall T
        ::Spectator::Expectation.new(actual)
      end
    end
  end
end
