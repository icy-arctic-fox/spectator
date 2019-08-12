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
  def should(matcher : ::Spectator::Matchers::Matcher)
    # First argument of the `Expectation` initializer is the expression label.
    # However, since this isn't a macro and we can't "look behind" this method call
    # to see what it was invoked on, the argument is an empty string.
    # Additionally, the source file and line can't be obtained.
    actual = ::Spectator::TestValue.new(self)
    source = ::Spectator::Source.new(__FILE__, __LINE__)
    ::Spectator::Expectations::ExpectationPartial.new(actual, source).to(matcher)
  end

  # Works the same as `#should` except the condition is inverted.
  # When `#should` succeeds, this method will fail, and vice-versa.
  def should_not(matcher : ::Spectator::Matchers::Matcher)
    actual = ::Spectator::TestValue.new(self)
    source = ::Spectator::Source.new(__FILE__, __LINE__)
    ::Spectator::Expectations::ExpectationPartial.new(actual, source).to_not(matcher)
  end
end

struct Proc(*T, R)
  # Extension method to create an expectation for a block of code (proc).
  # Depending on the matcher, the proc may be executed multiple times.
  def should(matcher : ::Spectator::Matchers::Matcher)
    actual = ::Spectator::TestBlock.new(self)
    source = ::Spectator::Source.new(__FILE__, __LINE__)
    ::Spectator::Expectations::ExpectationPartial.new(actual, source).to(matcher)
  end

  # Works the same as `#should` except the condition is inverted.
  # When `#should` succeeds, this method will fail, and vice-versa.
  def should_not(matcher : ::Spectator::Matchers::Matcher)
    actual = ::Spectator::TestBlock.new(self)
    source = ::Spectator::Source.new(__FILE__, __LINE__)
    ::Spectator::Expectations::BlockExpectationPartial.new(actual, source).to_not(matcher)
  end
end
