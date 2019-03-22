require "../spec_helper"

# This is a terrible hack,
# but I don't want to expose `ValueMatcher#expected` publicly
# just for this spec.
module Spectator::Matchers
  struct ValueMatcher(ExpectedType)
    def expected_value
      expected
    end
  end
end

def be_comparison
  Spectator::Matchers::TruthyMatcher.new(true)
end

describe Spectator::Matchers::TruthyMatcher do
  describe "#match" do
    context "returned MatchData" do
      context "truthy" do
        describe "#matched?" do
          context "with a truthy value" do
            it "is true" do
              value = 42
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(true)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "with false" do
            it "is false" do
              value = false
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(true)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "with nil" do
            it "is false" do
              value = nil
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(true)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end
        end

        describe "#values" do
          context "expected" do
            it "contains the definition of falsey" do
              value = 42
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(true)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data, :expected)[:to_s].should match(/false or nil/i)
            end

            it "is prefixed with \"Not\"" do
              value = 42
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(true)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data, :expected)[:to_s].should start_with(/not/i)
            end
          end

          context "actual" do
            it "is the actual value" do
              value = 42
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(true)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data, :actual)[:value].should eq(value)
            end
          end

          context "truthy" do
            context "when the actual value is truthy" do
              it "is true" do
                value = 42
                partial = new_partial(value)
                matcher = Spectator::Matchers::TruthyMatcher.new(true)
                match_data = matcher.match(partial)
                match_data_value_sans_prefix(match_data, :truthy)[:value].should be_true
              end
            end

            context "when the actual value is false" do
              it "is false" do
                value = false
                partial = new_partial(value)
                matcher = Spectator::Matchers::TruthyMatcher.new(true)
                match_data = matcher.match(partial)
                match_data_value_sans_prefix(match_data, :truthy)[:value].should be_false
              end
            end

            context "when the actual value is nil" do
              it "is false" do
                value = nil
                partial = new_partial(value)
                matcher = Spectator::Matchers::TruthyMatcher.new(true)
                match_data = matcher.match(partial)
                match_data_value_sans_prefix(match_data, :truthy)[:value].should be_false
              end
            end
          end
        end

        describe "#message" do
          it "contains the actual label" do
            value = 42
            label = "everything"
            partial = new_partial(value, label)
            matcher = Spectator::Matchers::TruthyMatcher.new(true)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the \"truthy\"" do
            value = 42
            label = "everything"
            partial = new_partial(value)
            matcher = Spectator::Matchers::TruthyMatcher.new(true)
            match_data = matcher.match(partial)
            match_data.message.should contain("truthy")
          end
        end

        describe "#negated_message" do
          it "contains the actual label" do
            value = 42
            label = "everything"
            partial = new_partial(value, label)
            matcher = Spectator::Matchers::TruthyMatcher.new(true)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the \"truthy\"" do
            value = 42
            label = "everything"
            partial = new_partial(value)
            matcher = Spectator::Matchers::TruthyMatcher.new(true)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain("truthy")
          end
        end
      end

      context "falsey" do
        describe "#matched?" do
          context "with a truthy value" do
            it "is false" do
              value = 42
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(false)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "with false" do
            it "is true" do
              value = false
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(false)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "with nil" do
            it "is true" do
              value = nil
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(false)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end
        end

        describe "#values" do
          context "expected" do
            it "contains the definition of falsey" do
              value = 42
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(false)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data, :expected)[:to_s].should match(/false or nil/i)
            end

            it "is not prefixed with \"Not\"" do
              value = 42
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(false)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data, :expected)[:to_s].should_not start_with(/not/i)
            end
          end

          context "actual" do
            it "is the actual value" do
              value = 42
              partial = new_partial(value)
              matcher = Spectator::Matchers::TruthyMatcher.new(false)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data, :actual)[:value].should eq(value)
            end
          end

          context "truthy" do
            context "when the actual value is truthy" do
              it "is true" do
                value = 42
                partial = new_partial(value)
                matcher = Spectator::Matchers::TruthyMatcher.new(false)
                match_data = matcher.match(partial)
                match_data_value_sans_prefix(match_data, :truthy)[:value].should be_true
              end
            end

            context "when the actual value is false" do
              it "is false" do
                value = false
                partial = new_partial(value)
                matcher = Spectator::Matchers::TruthyMatcher.new(false)
                match_data = matcher.match(partial)
                match_data_value_sans_prefix(match_data, :truthy)[:value].should be_false
              end
            end

            context "when the actual value is nil" do
              it "is false" do
                value = nil
                partial = new_partial(value)
                matcher = Spectator::Matchers::TruthyMatcher.new(false)
                match_data = matcher.match(partial)
                match_data_value_sans_prefix(match_data, :truthy)[:value].should be_false
              end
            end
          end
        end

        describe "#message" do
          it "contains the actual label" do
            value = 42
            label = "everything"
            partial = new_partial(value, label)
            matcher = Spectator::Matchers::TruthyMatcher.new(false)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the \"falsey\"" do
            value = 42
            label = "everything"
            partial = new_partial(value)
            matcher = Spectator::Matchers::TruthyMatcher.new(false)
            match_data = matcher.match(partial)
            match_data.message.should contain("falsey")
          end
        end

        describe "#negated_message" do
          it "contains the actual label" do
            value = 42
            label = "everything"
            partial = new_partial(value, label)
            matcher = Spectator::Matchers::TruthyMatcher.new(false)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the \"falsey\"" do
            value = 42
            label = "everything"
            partial = new_partial(value)
            matcher = Spectator::Matchers::TruthyMatcher.new(false)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain("falsey")
          end
        end
      end
    end
  end

  describe "#<" do
    it "returns a LessThanMatcher" do
      value = 0
      matcher = be_comparison < value
      matcher.should be_a(Spectator::Matchers::LessThanMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison < value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#<=" do
    it "returns a LessThanEqualMatcher" do
      value = 0
      matcher = be_comparison <= value
      matcher.should be_a(Spectator::Matchers::LessThanEqualMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison <= value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#>" do
    it "returns a GreaterThanMatcher" do
      value = 0
      matcher = be_comparison > value
      matcher.should be_a(Spectator::Matchers::GreaterThanMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison > value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#>=" do
    it "returns a GreaterThanEqualMatcher" do
      value = 0
      matcher = be_comparison >= value
      matcher.should be_a(Spectator::Matchers::GreaterThanEqualMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison >= value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#==" do
    it "returns an EqualityMatcher" do
      value = 0
      matcher = be_comparison == value
      matcher.should be_a(Spectator::Matchers::EqualityMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison == value
      matcher.expected_value.should eq(value)
    end
  end

  describe "#!=" do
    it "returns an InequalityMatcher" do
      value = 0
      matcher = be_comparison != value
      matcher.should be_a(Spectator::Matchers::InequalityMatcher(typeof(value)))
    end

    it "passes along the expected value" do
      value = 42
      matcher = be_comparison != value
      matcher.expected_value.should eq(value)
    end
  end
end
