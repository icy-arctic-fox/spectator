require "./expectation_partial"

module Spectator::Expectations
  class ValueExpectationPartial(ActualType) < ExpectationPartial
    getter actual

    protected def initialize(label : String, @actual : ActualType)
      super(label)
    end

    def to(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      expectation = ValueExpectation.new(self, matcher)
      result = expectation.eval
      ExpectationRegistry.current.report(result)
    end

    def to_not(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      expectation = ValueExpectation.new(self, matcher)
      result = expectation.eval(true)
      ExpectationRegistry.current.report(result)
    end

    # ditto
    @[AlwaysInline]
    def not_to(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      to_not(matcher)
    end
  end
end
