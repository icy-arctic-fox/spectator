require "./expectation_partial"

module Spectator::Expectations
  # Expectation partial variation that operates on a value.
  struct ValueExpectationPartial(ActualType) < ExpectationPartial
    # Actual value produced by the test.
    # This is the value passed to the `#expect` call.
    getter actual

    # Creates the expectation partial.
    protected def initialize(label : String, @actual : ActualType)
      super(label)
    end

    # Asserts that the `#actual` value matches some criteria.
    # The criteria is defined by the matcher passed to this method.
    def to(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      expectation = ValueExpectation.new(self, matcher)
      result = expectation.eval
      ExpectationRegistry.current.report(result)
    end

    # Asserts that the `#actual` value *does not* match some criteria.
    # This is effectively the opposite of `#to`.
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
