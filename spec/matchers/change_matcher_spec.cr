require "../spec_helper"

describe Spectator::Matchers::ChangeMatcher do
  describe "#match" do
    context "returned MatchData" do
      context "with a static expression" do
        describe "#matched?" do
          it "is false" do
            i = 0
            partial = new_block_partial { i += 0 }
            matcher = Spectator::Matchers::ChangeMatcher.new { i }
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      context "with changing expression" do
        describe "#matched?" do
          it "is true" do
            i = 0
            partial = new_block_partial { i += 5 }
            matcher = Spectator::Matchers::ChangeMatcher.new { i }
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        describe "#values" do
          context "before" do
            it "is the initial value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeMatcher.new { i }
              match_data = matcher.match(partial)
              match_data_value_with_key(match_data.values, :before).value.should eq(0)
            end
          end

          context "after" do
            it "is the resulting value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeMatcher.new { i }
              match_data = matcher.match(partial)
              match_data_value_with_key(match_data.values, :after).value.should eq(5)
            end
          end
        end

        describe "#message" do
          it "contains the action label" do
            i = 0
            label = "ACTION"
            partial = new_block_partial(label) { i += 5 }
            matcher = Spectator::Matchers::ChangeMatcher.new { i }
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expression label" do
            i = 0
            label = "EXPRESSION"
            partial = new_block_partial { i += 5 }
            matcher = Spectator::Matchers::ChangeMatcher.new(label) { i }
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end
        end

        describe "#negated_message" do
          it "contains the action label" do
            i = 0
            label = "ACTION"
            partial = new_block_partial(label) { i += 5 }
            matcher = Spectator::Matchers::ChangeMatcher.new { i }
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expression label" do
            i = 0
            label = "EXPRESSION"
            partial = new_block_partial { i += 5 }
            matcher = Spectator::Matchers::ChangeMatcher.new(label) { i }
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end
        end
      end
    end
  end

  describe "#from" do
    it "returns a ChangeFromMatcher" do
      i = 0
      matcher = Spectator::Matchers::ChangeMatcher.new { i }
      matcher.from(0).should be_a(Spectator::Matchers::ChangeFromMatcher(Int32, Int32))
    end

    it "passes along the expected from value" do
      i = 0
      partial = new_block_partial { i += 5 }
      matcher = Spectator::Matchers::ChangeMatcher.new { i }
      match_data = matcher.from(0).match(partial)
      match_data_value_with_key(match_data.values, :"expected before").value.should eq(0)
    end

    it "passes along the expression" do
      i = 0
      partial = new_block_partial { i += 5 }
      matcher = Spectator::Matchers::ChangeMatcher.new { i }
      matcher.from(0).match(partial)
      i.should eq(5) # Local scope `i` will be updated if the expression (closure) was passed on.
    end

    it "passes along the label" do
      i = 0
      label = "EXPRESSION"
      partial = new_block_partial { i += 5 }
      matcher = Spectator::Matchers::ChangeMatcher.new(label) { i }
      match_data = matcher.from(0).match(partial)
      match_data.message.should contain(label)
    end
  end

  describe "#to" do
    it "returns a ChangeToMatcher" do
      i = 0
      matcher = Spectator::Matchers::ChangeMatcher.new { i }
      matcher.to(0).should be_a(Spectator::Matchers::ChangeToMatcher(Int32, Int32))
    end

    it "passes along the expected to value" do
      i = 0
      partial = new_block_partial { i += 5 }
      matcher = Spectator::Matchers::ChangeMatcher.new { i }
      match_data = matcher.to(5).match(partial)
      match_data_value_with_key(match_data.values, :"expected after").value.should eq(5)
    end

    it "passes along the expression" do
      i = 0
      partial = new_block_partial { i += 5 }
      matcher = Spectator::Matchers::ChangeMatcher.new { i }
      matcher.to(5).match(partial)
      i.should eq(5) # Local scope `i` will be updated if the expression (closure) was passed on.
    end

    it "passes along the label" do
      i = 0
      label = "EXPRESSION"
      partial = new_block_partial { i += 5 }
      matcher = Spectator::Matchers::ChangeMatcher.new(label) { i }
      match_data = matcher.to(5).match(partial)
      match_data.message.should contain(label)
    end
  end
end
