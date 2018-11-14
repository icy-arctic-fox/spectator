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
  matched = matcher.match?(partial)
  Spectator::Expectations::ValueExpectation.new(matched, false, partial, matcher)
end

def new_satisfied_expectation(value : T = 123) forall T
  new_expectation(value, value).tap do |expectation|
    expectation.satisfied?.should be_true # Sanity check.
  end
end

def new_unsatisfied_expectation(expected : ExpectedType = 123, actual : ActualType = 456) forall ExpectedType, ActualType
  new_expectation(expected, actual).tap do |expectation|
    expectation.satisfied?.should be_false # Sanity check.
  end
end

def generate_expectations(success_count = 1, failure_count = 0)
  satisfied = Array.new(success_count) { new_satisfied_expectation }
  unsatisfied = Array.new(failure_count) { new_unsatisfied_expectation }
  expectations = (satisfied + unsatisfied).shuffle
  reporter = Spectator::Expectations::ExpectationReporter.new(false)
  expectations.each do |expectation|
    reporter.report(expectation)
  end
  {satisfied: satisfied, unsatisfied: unsatisfied, expectations: expectations, reporter: reporter}
end

def report_expectations(success_count = 1, failure_count = 0)
  harness = Spectator::Internals::Harness.current
  success_count.times { harness.report_expectation(new_satisfied_expectation) }
  failure_count.times { harness.report_expectation(new_unsatisfied_expectation) }
end