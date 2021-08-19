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
  def should(matcher, message = nil)
    actual = ::Spectator::Value.new(self)
    match_data = matcher.match(actual)
    expectation = ::Spectator::Expectation.new(match_data, message: message)
    ::Spectator::Harness.current.report(expectation)
  end

  # Works the same as `#should` except the condition is inverted.
  # When `#should` succeeds, this method will fail, and vice-versa.
  def should_not(matcher, message = nil)
    actual = ::Spectator::Value.new(self)
    match_data = matcher.negated_match(actual)
    expectation = ::Spectator::Expectation.new(match_data, message: message)
    ::Spectator::Harness.current.report(expectation)
  end

  # Works the same as `#should` except that the condition check is postphoned.
  # The expectation is checked after the example finishes and all hooks have run.
  def should_eventually(matcher, message = nil)
    ::Spectator::Harness.current.defer { should(matcher, message) }
  end

  # Works the same as `#should_not` except that the condition check is postphoned.
  # The expectation is checked after the example finishes and all hooks have run.
  def should_never(matcher, message = nil)
    ::Spectator::Harness.current.defer { should_not(matcher, message) }
  end
end

struct Proc(*T, R)
  # Extension method to create an expectation for a block of code (proc).
  # Depending on the matcher, the proc may be executed multiple times.
  def should(matcher, message = nil)
    actual = ::Spectator::Block.new(self)
    match_data = matcher.match(actual)
    expectation = ::Spectator::Expectation.new(match_data, message: message)
    ::Spectator::Harness.current.report(expectation)
  end

  # Works the same as `#should` except the condition is inverted.
  # When `#should` succeeds, this method will fail, and vice-versa.
  def should_not(matcher, message = nil)
    actual = ::Spectator::Block.new(self)
    match_data = matcher.negated_match(actual)
    expectation = ::Spectator::Expectation.new(match_data, message: message)
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
