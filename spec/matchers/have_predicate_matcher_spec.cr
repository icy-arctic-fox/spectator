require "../spec_helper"

describe Spectator::Matchers::HavePredicateMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#match?" do
        context "with a true predicate" do
          it "is true" do
            value = "foo\\bar"
            partial = new_partial(value)
            matcher = Spectator::Matchers::HavePredicateMatcher.new({back_references: Tuple.new}, "back_references")
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with a false predicate" do
          it "is false" do
            value = "foobar"
            partial = new_partial(value)
            matcher = Spectator::Matchers::HavePredicateMatcher.new({back_references: Tuple.new}, "back_references")
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        it "contains a key for each expected attribute" do
          value = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::HavePredicateMatcher.new({back_references: Tuple.new}, "back_references")
          match_data = matcher.match(partial)
          match_data_has_key?(match_data.values, :back_references).should be_true
        end

        it "has the actual values" do
          value = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::HavePredicateMatcher.new({back_references: Tuple.new}, "back_references")
          match_data = matcher.match(partial)
          match_data_value_sans_prefix(match_data.values, :back_references)[:value].should eq(value.has_back_references?)
        end
      end

      describe "#message" do
        it "contains the actual label" do
          value = "foobar"
          label = "blah"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::HavePredicateMatcher.new({back_references: Tuple.new}, "back_references")
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          value = "foobar"
          label = "blah"
          partial = new_partial(value)
          matcher = Spectator::Matchers::HavePredicateMatcher.new({back_references: Tuple.new}, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          value = "foobar"
          label = "blah"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::HavePredicateMatcher.new({back_references: Tuple.new}, "back_references")
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          value = "foobar"
          label = "blah"
          partial = new_partial(value)
          matcher = Spectator::Matchers::HavePredicateMatcher.new({back_references: Tuple.new}, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end
      end
    end
  end
end
