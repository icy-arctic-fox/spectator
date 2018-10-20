require "./matcher_dsl"

module Spectator::DSL
  module ExampleDSL
    include MatcherDSL

    macro is_expected
      expect(subject)
    end

    macro expect(actual)
      ::Spectator::Expectations::ValueExpectationPartial.new({{actual.stringify}}, {{actual}})
    end

    def fail(reason : String)
      raise ExampleFailed.new(reason)
    end

    @[AlwaysInline]
    def fail
      fail("Example failed")
    end
  end
end
