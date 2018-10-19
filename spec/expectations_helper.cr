# Utility methods for creating expectations, partials, and matchers.

def new_partial(label : String, actual : T) forall T
  Spectator::Expectations::ValueExpectationPartial.new(label, actual)
end

def new_partial(actual : T = 123) forall T
  new_partial(actual.to_s, actual)
end

def new_matcher(label : String, expected : T) forall T
  Spectator::Matchers::EqualityMatcher.new(label, expected)
end

def new_matcher(expected : T = 123) forall T
  new_matcher(expected.to_s, expected)
end

def new_expectation(expected : ExpectedType = 123, actual : ActualType = 123) forall ExpectedType, ActualType
  partial = new_partial("foo", actual)
  matcher = new_matcher("bar", expected)
  Spectator::Expectations::ValueExpectation.new(partial, matcher)
end

def new_met_expectation(value : T = 123) forall T
  new_expectation(value, value)
end

def new_unmet_expectation(expected : ExpectedType = 123, actual : ActualType = 456) forall ExpectedType, ActualType
  new_expectation(expected, actual)
end

def new_successful_result
  new_met_expectation.eval.tap do |result|
    result.successful?.should be_true # Sanity check.
  end
end

def new_failure_result
  new_unmet_expectation.eval.tap do |result|
    result.successful?.should be_false # Sanity check.
  end
end
