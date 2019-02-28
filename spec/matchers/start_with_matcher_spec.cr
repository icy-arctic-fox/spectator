require "../spec_helper"

describe Spectator::Matchers::StartWithMatcher do
  describe "#match?" do
    context "with a String" do
      context "against a matching string" do
        it "is true" do
          value = "foobar"
          start = "foo"
          partial = new_partial(value)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_true
        end

        context "not at start" do
          it "is false" do
            value = "foobar"
            start = "bar"
            partial = new_partial(value)
            matcher = Spectator::Matchers::StartWithMatcher.new(start)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a different string" do
        it "is false" do
          value = "foobar"
          start = "baz"
          partial = new_partial(value)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_false
        end
      end

      context "against a matching character" do
        it "is true" do
          value = "foobar"
          start = 'f'
          partial = new_partial(value)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_true
        end

        context "not at start" do
          it "is false" do
            value = "foobar"
            start = 'b'
            partial = new_partial(value)
            matcher = Spectator::Matchers::StartWithMatcher.new(start)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a different character" do
        it "is false" do
          value = "foobar"
          start = 'z'
          partial = new_partial(value)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_false
        end
      end

      context "against a matching regex" do
        it "is true" do
          value = "FOOBAR"
          start = /foo/i
          partial = new_partial(value)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_true
        end

        context "not at start" do
          it "is false" do
            value = "FOOBAR"
            start = /bar/i
            partial = new_partial(value)
            matcher = Spectator::Matchers::StartWithMatcher.new(start)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a non-matching regex" do
        it "is false" do
          value = "FOOBAR"
          start = /baz/i
          partial = new_partial(value)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_false
        end
      end
    end

    context "with an Enumberable" do
      context "against an equal value" do
        it "is true" do
          array = %i[a b c]
          start = :a
          partial = new_partial(array)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_true
        end

        context "not at start" do
          it "is false" do
            array = %i[a b c]
            start = :b
            partial = new_partial(array)
            matcher = Spectator::Matchers::StartWithMatcher.new(start)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a different value" do
        it "is false" do
          array = %i[a b c]
          start = :z
          partial = new_partial(array)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_false
        end
      end

      context "against matching element type" do
        it "is true" do
          array = %i[a b c]
          partial = new_partial(array)
          matcher = Spectator::Matchers::StartWithMatcher.new(Symbol)
          matcher.match?(partial).should be_true
        end

        context "not at start" do
          it "is false" do
            array = [1, 2, 3, :a, :b, :c]
            partial = new_partial(array)
            matcher = Spectator::Matchers::StartWithMatcher.new(Symbol)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against different element type" do
        it "is false" do
          array = %i[a b c]
          partial = new_partial(array)
          matcher = Spectator::Matchers::StartWithMatcher.new(Int32)
          matcher.match?(partial).should be_false
        end
      end

      context "against a matching regex" do
        it "is true" do
          array = %w[FOO BAR BAZ]
          start = /foo/i
          partial = new_partial(array)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_true
        end

        context "not at start" do
          it "is false" do
            array = %w[FOO BAR BAZ]
            start = /bar/i
            partial = new_partial(array)
            matcher = Spectator::Matchers::StartWithMatcher.new(start)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a non-matching regex" do
        it "is false" do
          array = %w[FOO BAR BAZ]
          start = /qux/i
          partial = new_partial(array)
          matcher = Spectator::Matchers::StartWithMatcher.new(start)
          matcher.match?(partial).should be_false
        end
      end
    end
  end

  describe "#message" do
    context "with a String" do
      it "mentions #starts_with?" do
        value = "foobar"
        start = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::StartWithMatcher.new(start)
        matcher.message(partial).should contain("#starts_with?")
      end
    end

    context "with an Enumerable" do
      it "mentions ===" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::StartWithMatcher.new(array.first)
        matcher.message(partial).should contain("===")
      end

      it "mentions first" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::StartWithMatcher.new(array.first)
        matcher.message(partial).should contain("first")
      end
    end

    it "contains the actual label" do
      value = "foobar"
      start = "baz"
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::StartWithMatcher.new(start)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      start = "baz"
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::StartWithMatcher.new(start, label)
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        start = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::StartWithMatcher.new(start)
        matcher.message(partial).should contain(start)
      end
    end
  end

  describe "#negated_message" do
    context "with a String" do
      it "mentions #starts_with?" do
        value = "foobar"
        start = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::StartWithMatcher.new(start)
        matcher.negated_message(partial).should contain("#starts_with?")
      end
    end

    context "with an Enumerable" do
      it "mentions ===" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::StartWithMatcher.new(array.first)
        matcher.negated_message(partial).should contain("===")
      end

      it "mentions first" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::StartWithMatcher.new(array.first)
        matcher.negated_message(partial).should contain("first")
      end
    end

    it "contains the actual label" do
      value = "foobar"
      start = "baz"
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::StartWithMatcher.new(start)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      start = "baz"
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::StartWithMatcher.new(start, label)
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        start = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::StartWithMatcher.new(start)
        matcher.negated_message(partial).should contain(start)
      end
    end
  end
end
