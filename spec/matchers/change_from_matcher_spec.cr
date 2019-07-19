require "../spec_helper"

describe Spectator::Matchers::ChangeFromMatcher do
  describe "#match" do
    context "returned MatchData" do
      context "with a static expression" do
        describe "#matched?" do
          it "is false" do
            i = 0
            partial = new_block_partial { i += 0 }
            matcher = Spectator::Matchers::ChangeFromMatcher.new(i) { i }
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
            matcher = Spectator::Matchers::ChangeFromMatcher.new(i) { i }
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        describe "#values" do
          context "expected before" do
            it "is the expected value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeFromMatcher.new(0) { i }
              match_data = matcher.match(partial)
              match_data_value_with_key(match_data.values, :"expected before").value.should eq(0)
            end
          end

          context "actual before" do
            it "is the initial value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeFromMatcher.new(0) { i }
              match_data = matcher.match(partial)
              match_data_value_with_key(match_data.values, :"actual before").value.should eq(0)
            end
          end

          context "expected after" do
            it "is the negated initial value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeFromMatcher.new(0) { i }
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :"expected after")[:value].should eq(0)
              match_data_value_sans_prefix(match_data.values, :"expected after")[:to_s].should start_with("Not ")
            end
          end

          context "actual after" do
            it "is the resulting value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeFromMatcher.new(0) { i }
              match_data = matcher.match(partial)
              match_data_value_with_key(match_data.values, :"actual after").value.should eq(5)
            end
          end
        end

        describe "#message" do
          it "contains the action label" do
            i = 0
            label = "ACTION"
            partial = new_block_partial(label) { i += 5 }
            matcher = Spectator::Matchers::ChangeFromMatcher.new(i) { i }
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expression label" do
            i = 0
            label = "EXPRESSION"
            partial = new_block_partial { i += 5 }
            matcher = Spectator::Matchers::ChangeFromMatcher.new(label, i) { i }
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end
        end

        describe "#negated_message" do
          it "contains the action label" do
            i = 0
            label = "ACTION"
            partial = new_block_partial(label) { i += 5 }
            matcher = Spectator::Matchers::ChangeFromMatcher.new(i) { i }
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expression label" do
            i = 0
            label = "EXPRESSION"
            partial = new_block_partial { i += 5 }
            matcher = Spectator::Matchers::ChangeFromMatcher.new(label, i) { i }
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end
        end
      end

      context "with the wrong initial value" do
        describe "#matched?" do
          it "is false" do
            i = 0
            partial = new_block_partial { i += 5 }
            matcher = Spectator::Matchers::ChangeFromMatcher.new(2) { i }
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        describe "#values" do
          context "expected before" do
            it "is the expected value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeFromMatcher.new(2) { i }
              match_data = matcher.match(partial)
              match_data_value_with_key(match_data.values, :"expected before").value.should eq(2)
            end
          end

          context "actual before" do
            it "is the initial value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeFromMatcher.new(2) { i }
              match_data = matcher.match(partial)
              match_data_value_with_key(match_data.values, :"actual before").value.should eq(0)
            end
          end

          context "expected after" do
            it "is the negated initial value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeFromMatcher.new(2) { i }
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :"expected after")[:value].should eq(2)
              match_data_value_sans_prefix(match_data.values, :"expected after")[:to_s].should start_with("Not ")
            end
          end

          context "actual after" do
            it "is the resulting value" do
              i = 0
              partial = new_block_partial { i += 5 }
              matcher = Spectator::Matchers::ChangeFromMatcher.new(2) { i }
              match_data = matcher.match(partial)
              match_data_value_with_key(match_data.values, :"actual after").value.should eq(5)
            end
          end
        end

        describe "#message" do
          it "contains the expression label" do
            i = 0
            label = "EXPRESSION"
            partial = new_block_partial { i += 5 }
            matcher = Spectator::Matchers::ChangeFromMatcher.new(label, 2) { i }
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end
        end

        describe "#negated_message" do
          it "contains the expression label" do
            i = 0
            label = "EXPRESSION"
            partial = new_block_partial { i += 5 }
            matcher = Spectator::Matchers::ChangeFromMatcher.new(label, 2) { i }
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end
        end
      end
    end
  end
end
