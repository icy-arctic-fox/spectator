require "../spec_helper"

describe Spectator::Matchers::NilMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "with nil" do
          it "is true" do
            value = nil.as(Bool?)
            partial = new_partial(value)
            matcher = Spectator::Matchers::NilMatcher.new
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with not nil" do
          it "is false" do
            value = true.as(Bool?)
            partial = new_partial(value)
            matcher = Spectator::Matchers::NilMatcher.new
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "expected" do
          it "is nil" do
            partial = new_partial(42)
            matcher = Spectator::Matchers::NilMatcher.new
            match_data = matcher.match(partial)
            match_data.values[:expected].value.should eq(nil)
          end
        end

        context "actual" do
          it "is the actual value" do
            value = 42
            partial = new_partial(value)
            matcher = Spectator::Matchers::NilMatcher.new
            match_data = matcher.match(partial)
            match_data.values[:actual].should eq(value)
          end
        end
      end

      describe "#message" do
        it "mentions nil" do
          partial = new_partial(42)
          matcher = Spectator::Matchers::NilMatcher.new
          match_data = matcher.match(partial)
          match_data.message.should contain("nil")
        end

        it "contains the actual label" do
          value = 42
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::NilMatcher.new
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end
      end

      describe "#negated_message" do
        it "mentions nil" do
          partial = new_partial(42)
          matcher = Spectator::Matchers::NilMatcher.new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("nil")
        end

        it "contains the actual label" do
          value = 42
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::NilMatcher.new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end
      end
    end
  end
end
