require "./matcher_dsl"

module Spectator
  module DSL
    module ExampleDSL
      include MatcherDSL

      macro is_expected
        expect(subject)
      end

      macro expect(actual)
        ::Spectator::Expectation.new({{actual.stringify}}, {{actual}})
      end
    end
  end
end
