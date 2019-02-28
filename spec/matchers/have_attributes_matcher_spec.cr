require "../spec_helper"

describe Spectator::Matchers::AttributesMatcher do
  describe "#match?" do
    it "uses ===" do
      array = %i[a b c]
      spy = SpySUT.new
      partial = new_partial(array)
      matcher = Spectator::Matchers::HaveMatcher.new({spy})
      matcher.match?(partial).should be_true
      spy.case_eq_call_count.should be > 0
    end

    context "one argument" do
      context "against an equal value" do
        it "is true" do
          array = %i[a b c]
          attributes = {first: :a}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_true
        end
      end

      context "against a different value" do
        it "is false" do
          array = %i[a b c]
          attributes = {first: :z}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end

      context "against a matching type" do
        it "is true" do
          array = %i[a b c]
          attributes = {first: Symbol}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_true
        end
      end

      context "against a non-matching type" do
        it "is false" do
          array = %i[a b c]
          attributes = {first: Int32}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end

      context "against a matching regex" do
        it "is true" do
          array = %w[FOO BAR BAZ]
          attributes = {first: /foo/i}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_true
        end
      end

      context "against a non-matching regex" do
        it "is false" do
          array = %w[FOO BAR BAZ]
          attributes = {first: /qux/i}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end
    end

    context "multiple attributes" do
      context "against equal values" do
        it "is true" do
          array = %i[a b c]
          attributes = {first: :a, last: :c}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_true
        end

        context "matching type" do
          context "matching regex" do
            it "is true" do
              array = [:a, 42, "FOO"]
              attributes = {first: Symbol, last: /foo/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              matcher.match?(partial).should be_true
            end
          end

          context "non-matching regex" do
            it "is false" do
              array = [:a, 42, "FOO"]
              attributes = {first: Symbol, last: /bar/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              matcher.match?(partial).should be_false
            end
          end
        end

        context "non-matching type" do
          context "matching regex" do
            it "is false" do
              array = [:a, 42, "FOO"]
              attributes = {first: Float32, last: /foo/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              matcher.match?(partial).should be_false
            end
          end

          context "non-matching regex" do
            it "is false" do
              array = [:a, 42, "FOO"]
              attributes = {first: Float32, last: /bar/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              matcher.match?(partial).should be_false
            end
          end
        end
      end

      context "against one equal value" do
        it "is false" do
          array = %i[a b c]
          attributes = {first: :a, last: :d}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end

      context "against no equal values" do
        it "is false" do
          array = %i[a b c]
          attributes = {first: :d, last: :e}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end

      context "against matching types" do
        it "is true" do
          array = [:a, 42, "FOO"]
          attributes = {first: Symbol, last: String}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_true
        end
      end

      context "against one matching type" do
        it "is false" do
          array = [:a, 42, "FOO"]
          attributes = {first: Symbol, last: Float32}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end

      context "against no matching types" do
        it "is false" do
          array = [:a, 42, "FOO"]
          attributes = {first: Float32, last: Bytes}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end

      context "against matching regexes" do
        it "is true" do
          array = %w[FOO BAR BAZ]
          attributes = {first: /foo/i, last: /baz/i}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_true
        end
      end

      context "against one matching regex" do
        it "is false" do
          array = %w[FOO BAR BAZ]
          attributes = {first: /foo/i, last: /qux/i}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end

      context "against no matching regexes" do
        it "is false" do
          array = %w[FOO BAR]
          attributes = {first: /baz/i, last: /qux/i}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_false
        end
      end

      context "against equal and matching type and regex" do
        it "is true" do
          array = [:a, 42, "FOO"]
          attributes = {first: Symbol, last: /foo/i, size: 3}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          matcher.match?(partial).should be_true
        end
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      value = "foobar"
      attributes = {size: 6}
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      attributes = {size: 6}
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::AttributesMatcher.new(attributes, label)
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        attributes = {size: 6}
        partial = new_partial(value)
        matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
        matcher.message(partial).should contain(attributes.to_s)
      end
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      value = "foobar"
      attributes = {size: 6}
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      attributes = {size: 6}
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::AttributesMatcher.new(attributes, label)
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        attributes = {size: 6}
        partial = new_partial(value)
        matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
        matcher.negated_message(partial).should contain(attributes.to_s)
      end
    end
  end
end
