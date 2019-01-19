require "../matchers"

module Spectator::DSL
  # Methods for defining matchers for expectations.
  module MatcherDSL
    # Indicates that some value should equal another.
    # The `==` operator is used for this check.
    # The value passed to this method is the expected value.
    #
    # Example:
    # ```
    # expect(1 + 2).to eq(3)
    # ```
    macro eq(expected)
      ::Spectator::Matchers::EqualityMatcher.new({{expected.stringify}}, {{expected}})
    end

    # Indicates that some value should semantically equal another.
    # The `===` operator is used for this check.
    # This has identical behavior as a `when` condition in a `case` block.
    #
    # Examples:
    # ```
    # expect(1 + 2).to be(3)
    # expect(5).to be(Int32) # Using `#be_a` instead is recommened here.
    # expect(tuple).to be({1, 2})
    # ```
    macro be(expected)
      ::Spectator::Matchers::CaseMatcher.new({{expected.stringify}}, {{expected}})
    end

    # Indicates that some value should be of a specified type.
    # The `#is_a?` method is used for this check.
    # A type name or type union should be used for `expected`.
    #
    # Examples:
    # ```
    # expect("foo").to be_a(String)
    #
    # x = Random.rand(2) == 0 ? "foobar" : 5
    # expect(x).to be_a(Int32 | String)
    # ```
    macro be_a(expected)
      ::Spectator::Matchers::TypeMatcher({{expected}}).new
    end
  end
end
