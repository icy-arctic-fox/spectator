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
    # expect(5).to be(.odd?) # Using `#be_odd` instead is recommended here.
    # expect(tuple).to be({1, 2})
    # ```
    #
    # See https://crystal-lang.org/reference/syntax_and_semantics/case.html
    # for more examples of what could be used here.
    macro be(expected)
      ::Spectator::Matchers::CaseMatcher.new({{expected.stringify}}, {{expected}})
    end
  end
end
