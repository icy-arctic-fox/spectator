class Object
  # Extension method to create an expectation for an object.
  # This is part of the spec DSL and mimics Crystal Spec's default should-syntax.
  # A matcher should immediately follow this method, or be the only argument to it.
  # Example usage:
  # ```
  # it "equals the expected value" do
  #   subject.should eq(42)
  # end
  # ```
  #
  # An optional message can be used in case the expectation fails.
  # It can be a string or proc returning a string.
  # ```
  # subject.should_not be_nil, "Shouldn't be nil"
  # ```
  #
  # NOTE: By default, the should-syntax is disabled.
  # The expect-syntax is preferred,
  # since it doesn't [monkey-patch](https://en.wikipedia.org/wiki/Monkey_patch) all objects.
  # To enable should-syntax, add the following to your `spec_helper.cr` file:
  # ```
  # require "spectator/should"
  # ```
  def should(matcher, message = nil, *, _file = __FILE__, _line = __LINE__)
    actual = ::Spectator::Value.new(self)
    location = ::Spectator::Location.new(_file, _line)
    match_data = matcher.match(actual)
    expectation = ::Spectator::Expectation.new(match_data, location, message)
    ::Spectator::Harness.current.report(expectation)
  end

  # Asserts that some criteria defined by the matcher is satisfied.
  # Allows a custom message to be used.
  # Returns the expected value cast as the expected type, if the matcher is satisfied.
  def should(matcher : ::Spectator::Matchers::TypeMatcher(U), message = nil, *, _file = __FILE__, _line = __LINE__) forall U
    actual = ::Spectator::Value.new(self)
    location = ::Spectator::Location.new(_file, _line)
    match_data = matcher.match(actual)
    expectation = ::Spectator::Expectation.new(match_data, location, message)
    if ::Spectator::Harness.current.report(expectation)
      return self if self.is_a?(U)

      raise "Spectator bug: expected value should have cast to #{U}"
    else
      raise TypeCastError.new("Expected value should be a #{U}, but was actually #{self.class}")
    end
  end

  # Works the same as `#should` except the condition is inverted.
  # When `#should` succeeds, this method will fail, and vice-versa.
  def should_not(matcher, message = nil, *, _file = __FILE__, _line = __LINE__)
    actual = ::Spectator::Value.new(self)
    location = ::Spectator::Location.new(_file, _line)
    match_data = matcher.negated_match(actual)
    expectation = ::Spectator::Expectation.new(match_data, location, message)
    ::Spectator::Harness.current.report(expectation)
  end

  # Asserts that some criteria defined by the matcher is not satisfied.
  # Allows a custom message to be used.
  # Returns the expected value cast without the unexpected type, if the matcher is satisfied.
  def should_not(matcher : ::Spectator::Matchers::TypeMatcher(U), message = nil, *, _file = __FILE__, _line = __LINE__) forall U
    actual = ::Spectator::Value.new(self)
    location = ::Spectator::Location.new(_file, _line)
    match_data = matcher.negated_match(actual)
    expectation = ::Spectator::Expectation.new(match_data, location, message)
    if ::Spectator::Harness.current.report(expectation)
      return self unless self.is_a?(U)

      raise "Spectator bug: expected value should not be #{U}"
    else
      raise TypeCastError.new("Expected value is not expected to be a #{U}, but was actually #{self.class}")
    end
  end

  # Asserts that some criteria defined by the matcher is not satisfied.
  # Allows a custom message to be used.
  # Returns the expected value cast as a non-nillable type, if the matcher is satisfied.
  def should_not(matcher : ::Spectator::Matchers::NilMatcher, message = nil, *, _file = __FILE__, _line = __LINE__)
    actual = ::Spectator::Value.new(self)
    location = ::Spectator::Location.new(_file, _line)
    match_data = matcher.negated_match(actual)
    expectation = ::Spectator::Expectation.new(match_data, location, message)
    if ::Spectator::Harness.current.report(expectation)
      return self unless self.nil?

      raise "Spectator bug: expected value should not be nil"
    else
      raise NilAssertionError.new("Expected value should not be nil.")
    end
  end

  # Works the same as `#should` except that the condition check is postponed.
  # The expectation is checked after the example finishes and all hooks have run.
  def should_eventually(matcher, message = nil, *, _file = __FILE__, _line = __LINE__)
    ::Spectator::Harness.current.defer { should(matcher, message, _file: _file, _line: _line) }
  end

  # Works the same as `#should_not` except that the condition check is postponed.
  # The expectation is checked after the example finishes and all hooks have run.
  def should_never(matcher, message = nil, *, _file = __FILE__, _line = __LINE__)
    ::Spectator::Harness.current.defer { should_not(matcher, message, _file: _file, _line: _line) }
  end
end

struct Proc(*T, R)
  # Extension method to create an expectation for a block of code (proc).
  # Depending on the matcher, the proc may be executed multiple times.
  def should(matcher, message = nil, *, _file = __FILE__, _line = __LINE__)
    actual = ::Spectator::Block.new(self)
    location = ::Spectator::Location.new(_file, _line)
    match_data = matcher.match(actual)
    expectation = ::Spectator::Expectation.new(match_data, location, message)
    ::Spectator::Harness.current.report(expectation)
  end

  # Works the same as `#should` except the condition is inverted.
  # When `#should` succeeds, this method will fail, and vice-versa.
  def should_not(matcher, message = nil, *, _file = __FILE__, _line = __LINE__)
    actual = ::Spectator::Block.new(self)
    location = ::Spectator::Location.new(_file, _line)
    match_data = matcher.negated_match(actual)
    expectation = ::Spectator::Expectation.new(match_data, location, message)
    ::Spectator::Harness.current.report(expectation)
  end
end

module Spectator::DSL::Expectations
  macro should(*args)
    expect(subject).to({{args.splat}})
  end

  macro should_not(*args)
    expect(subject).to_not({{args.splat}})
  end

  macro should_eventually(*args)
    expect(subject).to_eventually({{args.splat}})
  end

  macro should_never(*args)
    expect(subject).to_never({{args.splat}})
  end
end
