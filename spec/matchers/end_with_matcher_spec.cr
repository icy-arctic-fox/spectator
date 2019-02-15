require "../spec_helper"

describe Spectator::Matchers::EndWithMatcher do
  describe "#match?" do
    context "with a String" do
      context "against a matching string" do
        it "is true" do
          value = "foobar"
          last = "bar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_true
        end

        context "not at end" do
          it "is false" do
            value = "foobar"
            last = "foo"
            partial = new_partial(value)
            matcher = Spectator::Matchers::EndWithMatcher.new(last)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a different string" do
        it "is false" do
          value = "foobar"
          last = "baz"
          partial = new_partial(value)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_false
        end
      end

      context "against a matching character" do
        it "is true" do
          value = "foobar"
          last = 'r'
          partial = new_partial(value)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_true
        end

        context "not at end" do
          it "is false" do
            value = "foobar"
            last = 'b'
            partial = new_partial(value)
            matcher = Spectator::Matchers::EndWithMatcher.new(last)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a different character" do
        it "is false" do
          value = "foobar"
          last = 'z'
          partial = new_partial(value)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_false
        end
      end

      context "against a matching regex" do
        it "is true" do
          value = "FOOBAR"
          last = /bar/i
          partial = new_partial(value)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_true
        end

        context "not at end" do
          it "is false" do
            value = "FOOBAR"
            last = /foo/i
            partial = new_partial(value)
            matcher = Spectator::Matchers::EndWithMatcher.new(last)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a non-matching regex" do
        it "is false" do
          value = "FOOBAR"
          last = /baz/i
          partial = new_partial(value)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_false
        end
      end
    end

    context "with an Enumberable" do
      context "against an equal value" do
        it "is true" do
          array = %i[a b c]
          last = :c
          partial = new_partial(array)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_true
        end

        context "not at end" do
          it "is false" do
            array = %i[a b c]
            last = :b
            partial = new_partial(array)
            matcher = Spectator::Matchers::EndWithMatcher.new(last)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a different value" do
        it "is false" do
          array = %i[a b c]
          last = :z
          partial = new_partial(array)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_false
        end
      end

      context "against matching element type" do
        it "is true" do
          array = %i[a b c]
          partial = new_partial(array)
          matcher = Spectator::Matchers::EndWithMatcher.new(Symbol)
          matcher.match?(partial).should be_true
        end

        context "not at end" do
          it "is false" do
            array = [1, 2, 3, :a, :b, :c]
            partial = new_partial(array)
            matcher = Spectator::Matchers::EndWithMatcher.new(Int32)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against different element type" do
        it "is false" do
          array = %i[a b c]
          partial = new_partial(array)
          matcher = Spectator::Matchers::EndWithMatcher.new(Int32)
          matcher.match?(partial).should be_false
        end
      end

      context "against a matching regex" do
        it "is true" do
          array = %w[FOO BAR BAZ]
          last = /baz/i
          partial = new_partial(array)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_true
        end

        context "not at end" do
          it "is false" do
            array = %w[FOO BAR BAZ]
            last = /bar/i
            partial = new_partial(array)
            matcher = Spectator::Matchers::EndWithMatcher.new(last)
            matcher.match?(partial).should be_false
          end
        end
      end

      context "against a non-matching regex" do
        it "is false" do
          array = %w[FOO BAR BAZ]
          last = /qux/i
          partial = new_partial(array)
          matcher = Spectator::Matchers::EndWithMatcher.new(last)
          matcher.match?(partial).should be_false
        end
      end
    end
  end

  describe "#message" do
    context "with a String" do
      it "mentions #ends_with?" do
        value = "foobar"
        last = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::EndWithMatcher.new(last)
        matcher.message(partial).should contain("#starts_with?")
      end
    end

    context "with an Enumerable" do
      it "mentions ===" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::EndWithMatcher.new(array.last)
        matcher.message(partial).should contain("===")
      end

      it "mentions last" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::EndWithMatcher.new(array.last)
        matcher.message(partial).should contain("last")
      end
    end

    it "contains the actual label" do
      value = "foobar"
      last = "baz"
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::EndWithMatcher.new(last)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      last = "baz"
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::EndWithMatcher.new(label, last)
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        last = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::EndWithMatcher.new(last)
        matcher.message(partial).should contain(last)
      end
    end
  end

  describe "#negated_message" do
    context "with a String" do
      it "mentions #starts_with?" do
        value = "foobar"
        last = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::EndWithMatcher.new(last)
        matcher.negated_message(partial).should contain("#starts_with?")
      end
    end

    context "with an Enumerable" do
      it "mentions ===" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::EndWithMatcher.new(array.last)
        matcher.negated_message(partial).should contain("===")
      end

      it "mentions last" do
        array = %i[a b c]
        partial = new_partial(array)
        matcher = Spectator::Matchers::EndWithMatcher.new(array.last)
        matcher.negated_message(partial).should contain("last")
      end
    end

    it "contains the actual label" do
      value = "foobar"
      last = "baz"
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::EndWithMatcher.new(last)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      last = "baz"
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::EndWithMatcher.new(label, last)
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        last = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::EndWithMatcher.new(last)
        matcher.negated_message(partial).should contain(last)
      end
    end
  end
end
