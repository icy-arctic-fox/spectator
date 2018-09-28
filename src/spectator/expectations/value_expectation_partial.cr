require "./expectation_partial"

module Spectator::Expectations
  class ValueExpectationPartial(ActualType) < ExpectationPartial
    getter actual

    protected def initialize(label : String, @actual : ActualType)
      super(label)
    end

    def to(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      raise NotImplementedError.new("ValueExpectationPartial#to")
    end

    def to_not(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      raise NotImplementedError.new("ValueExpectationPartial#to_not")
    end

    # ditto
    @[AlwaysInline]
    def not_to(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      to_not(matcher)
    end
  end
end
