require "./matcher"

module Spectator::Matchers
  abstract struct ValueMatcher(ExpectedType) < Matcher
    private getter expected

    def initialize(label : String, @expected : ExpectedType)
      super(label)
    end

    abstract def match?(partial : ValueExpectationPartial(ActualType)) : Bool forall ActualType

    abstract def message(partial : ValueExpectationPartial(ActualType)) : String forall ActualType

    abstract def negated_message(partial : ValueExpectationPartial(ActualType)) : String forall ActualType
  end
end
