require "../spec_helper"

private struct FakeValueSet
  def has_value?(value)
    true
  end
end

describe Spectator::Matchers::HaveValueMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "with an existing value" do
          it "is true" do
            hash = Hash{"foo" => "bar"}
            value = "bar"
            partial = new_partial(hash)
            matcher = Spectator::Matchers::HaveValueMatcher.new(value)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with a non-existent value" do
          it "is false" do
            hash = Hash{"foo" => "bar"}
            value = "baz"
            partial = new_partial(hash)
            matcher = Spectator::Matchers::HaveValueMatcher.new(value)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "value" do
          it "is the expected value" do
            hash = {"foo" => "bar"}
            value = "baz"
            partial = new_partial(hash)
            matcher = Spectator::Matchers::HaveValueMatcher.new(value)
            match_data = matcher.match(partial)
            match_data.values[:value].value.should eq(value)
          end
        end

        context "actual" do
          context "when #values is available" do
            it "is the list of values" do
              hash = Hash{"foo" => "bar"}
              value = "baz"
              partial = new_partial(hash)
              matcher = Spectator::Matchers::HaveValueMatcher.new(value)
              match_data = matcher.match(partial)
              match_data.values[:actual].should eq(hash.values)
            end
          end

          context "when #values isn't available" do
            it "is the actual value" do
              actual = FakeValueSet.new
              value = "baz"
              partial = new_partial(actual)
              matcher = Spectator::Matchers::HaveValueMatcher.new(value)
              match_data = matcher.match(partial)
              match_data.values[:actual].should eq(actual)
            end
          end
        end
      end

      describe "#message" do
        it "contains the actual label" do
          hash = Hash{"foo" => "bar"}
          value = "bar"
          label = "blah"
          partial = new_partial(hash, label)
          matcher = Spectator::Matchers::HaveValueMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          hash = Hash{"foo" => "bar"}
          value = "bar"
          label = "blah"
          partial = new_partial(hash)
          matcher = Spectator::Matchers::HaveValueMatcher.new(value, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when the expected label is omitted" do
          it "contains the stringified key" do
            hash = Hash{"foo" => "bar"}
            value = "bar"
            partial = new_partial(hash)
            matcher = Spectator::Matchers::HaveValueMatcher.new(value)
            match_data = matcher.match(partial)
            match_data.message.should contain(value.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          hash = Hash{"foo" => "bar"}
          value = "bar"
          label = "blah"
          partial = new_partial(hash, label)
          matcher = Spectator::Matchers::HaveValueMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          hash = Hash{"foo" => "bar"}
          value = "bar"
          label = "blah"
          partial = new_partial(hash)
          matcher = Spectator::Matchers::HaveValueMatcher.new(value, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when the expected label is omitted" do
          it "contains the stringified key" do
            hash = Hash{"foo" => "bar"}
            value = "bar"
            partial = new_partial(hash)
            matcher = Spectator::Matchers::HaveValueMatcher.new(value)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(value.to_s)
          end
        end
      end
    end
  end
end
