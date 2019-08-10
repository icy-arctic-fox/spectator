# Utility methods for creating expectations, partials, and matchers.

def new_partial(actual : T, label : String) forall T
  test_value = Spectator::TestValue.new(actual, label)
  source = Spectator::Source.new(__FILE__, __LINE__)
  Spectator::Expectations::ExpectationPartial.new(test_value, source)
end

def new_partial(actual : T = 123) forall T
  test_value = Spectator::TestValue.new(actual)
  source = Spectator::Source.new(__FILE__, __LINE__)
  Spectator::Expectations::ExpectationPartial.new(test_value, source)
end

def new_block_partial(label = "BLOCK", &block)
  test_block = Spectator::TestBlock.new(block, label)
  source = Spectator::Source.new(__FILE__, __LINE__)
  Spectator::Expectations::ExpectationPartial.new(test_block, source)
end

def new_matcher(expected : T, label : String) forall T
  test_value = Spectator::TestValue.new(expected, label)
  Spectator::Matchers::EqualityMatcher.new(test_value)
end

def new_matcher(expected : T = 123) forall T
  test_value = Spectator::TestValue.new(expected)
  Spectator::Matchers::EqualityMatcher.new(test_value)
end

def new_expectation(expected : ExpectedType = 123, actual : ActualType = 123) forall ExpectedType, ActualType
  partial = new_partial(actual, "foo")
  matcher = new_matcher(expected, "bar")
  match_data = matcher.match(partial.actual)
  Spectator::Expectations::Expectation.new(match_data, partial.source)
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
