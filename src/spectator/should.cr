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
  # NOTE: By default, the should-syntax is disabled.
  # The expect-syntax is preferred,
  # since it doesn't [monkey-patch](https://en.wikipedia.org/wiki/Monkey_patch) all objects.
  # To enable should-syntax, add the following to your `spec_helper.cr` file:
  # ```
  # require "spectator/should"
  # ```
  def should(matcher)
    actual = ::Spectator::Value.new(self)
    match_data = matcher.match(actual)
    expectation = ::Spectator::Expectation.new(match_data)
    ::Spectator::Harness.current.report(expectation)
  end

  # Works the same as `#should` except the condition is inverted.
  # When `#should` succeeds, this method will fail, and vice-versa.
  def should_not(matcher)
    actual = ::Spectator::Value.new(self)
    match_data = matcher.negated_match(actual)
    expectation = ::Spectator::Expectation.new(match_data)
    ::Spectator::Harness.current.report(expectation)
  end

  # Works the same as `#should` except that the condition check is postphoned.
  # The expectation is checked after the example finishes and all hooks have run.
  def should_eventually(matcher)
    ::Spectator::Harness.current.defer { should(matcher) }
  end

  # Works the same as `#should_not` except that the condition check is postphoned.
  # The expectation is checked after the example finishes and all hooks have run.
  def should_never(matcher)
    ::Spectator::Harness.current.defer { should_not(matcher) }
  end
end

struct Proc(*T, R)
  # Extension method to create an expectation for a block of code (proc).
  # Depending on the matcher, the proc may be executed multiple times.
  def should(matcher)
    actual = ::Spectator::Block.new(self)
    match_data = matcher.match(actual)
    expectation = ::Spectator::Expectation.new(match_data)
    ::Spectator::Harness.current.report(expectation)
  end

  # Works the same as `#should` except the condition is inverted.
  # When `#should` succeeds, this method will fail, and vice-versa.
  def should_not(matcher)
    actual = ::Spectator::Block.new(self)
    match_data = matcher.negated_match(actual)
    expectation = ::Spectator::Expectation.new(match_data)
    ::Spectator::Harness.current.report(expectation)
  end
end

module Spectator::DSL::Assertions
  macro should(matcher)
    expect(subject).to({{matcher}})
  end

  macro should_not(matcher)
    expect(subject).to_not({{matcher}})
  end

  macro should_eventually(matcher)
    expect(subject).to_eventually({{matcher}})
  end

  macro should_never(matcher)
    expect(subject).to_never({{matcher}})
  end
end
