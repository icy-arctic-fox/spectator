# Utility methods for creating expectations, partials, and matchers.

def new_partial(actual : T, label : String) forall T
  Spectator::Expectations::ValueExpectationPartial.new(actual, label, __FILE__, __LINE__)
end

def new_partial(actual : T = 123) forall T
  Spectator::Expectations::ValueExpectationPartial.new(actual, __FILE__, __LINE__)
end

def new_matcher(expected : T, label : String) forall T
  Spectator::Matchers::EqualityMatcher.new(expected, label)
end

def new_matcher(expected : T = 123) forall T
  Spectator::Matchers::EqualityMatcher.new(expected)
end

def new_expectation(expected : ExpectedType = 123, actual : ActualType = 123) forall ExpectedType, ActualType
  partial = new_partial(actual, "foo")
  matcher = new_matcher(expected, "bar")
  match_data = matcher.match(partial)
  Spectator::Expectations::Expectation.new(match_data, false)
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

def create_expectations(success_count = 1, failure_count = 0)
  satisfied = Array.new(success_count) { new_satisfied_expectation }
  unsatisfied = Array.new(failure_count) { new_unsatisfied_expectation }
  (satisfied + unsatisfied).shuffle
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
