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

    # Indicates that some value when compared to another satisfies an operator.
    # An operator should follow, such as: `<`, `<=`, `>`, or `>=`.
    #
    # Examples:
    # ```
    # expect(1 + 1).to be > 1
    # expect(5).to be >= 3
    # ```
    #
    # See `Spectator::Matchers::BeComparison` for supported operators and methods.
    macro be
      ::Spectator::Matchers::BeComparison.new
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

    # Indicates that some value should match another.
    # The `=~` operator is used for this check.
    # Typically a regular expression is used,
    # but any type that has the `=~` operator will work.
    #
    # Examples:
    # ```
    # expect("foo").to match(/foo|bar/)
    # expect("BAR").to match(/foo|bar/i)
    # ```
    macro match(expected)
      ::Spectator::Matchers::RegexMatcher.new({{expected.stringify}}, {{expected}})
    end

    # Indicates that some value should be true.
    #
    # Examples:
    # ```
    # expect(nil.nil?).to be_true
    # expect(%i[a b c].any?).to be_true
    # ```
    macro be_true
      eq(true)
    end

    # Indicates that some value should be false.
    #
    # Examples:
    # ```
    # expect("foo".nil?).to be_false
    # expect(%i[a b c].empty?).to be_false
    # ```
    macro be_false
      eq(false)
    end

    # Indicates that some value should be truthy.
    # This means that the value is not `false` and not `nil`.
    #
    # Examples:
    # ```
    # expect(123).to be_truthy
    # expect(true).to be_truthy
    # ```
    macro be_truthy
      ::Spectator::Matchers::TruthyMatcher.new(true)
    end

    # Indicates that some value should be falsey.
    # This means that the value is either `false` or `nil`.
    #
    # Examples:
    # ```
    # expect(false).to be_falsey
    # expect(nil).to be_falsey
    # ```
    macro be_falsey
      ::Spectator::Matchers::TruthyMatcher.new(false)
    end
  end
end
