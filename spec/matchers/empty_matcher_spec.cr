require "../spec_helper"

describe Spectator::Matchers::EmptyMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "with an empty set" do
          it "is true" do
            array = [] of Symbol
            partial = new_partial(array)
            matcher = Spectator::Matchers::EmptyMatcher.new
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with a filled set" do
          it "is false" do
            array = %i[a b c]
            partial = new_partial(array)
            matcher = Spectator::Matchers::EmptyMatcher.new
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "expected" do
          it "is an empty set" do
            array = %i[a b c]
            partial = new_partial(array)
            matcher = Spectator::Matchers::EmptyMatcher.new
            match_data = matcher.match(partial)
            match_data.values[:expected].value.size.should eq(0)
          end
        end

        context "actual" do
          it "is the actual set" do
            array = %i[a b c]
            partial = new_partial(array)
            matcher = Spectator::Matchers::EmptyMatcher.new
            match_data = matcher.match(partial)
            match_data.values[:actual].should eq(array)
          end
        end
      end

      describe "#message" do
        it "contains the actual label" do
          array = %i[a b c]
          label = "everything"
          partial = new_partial(array, label)
          matcher = Spectator::Matchers::EmptyMatcher.new
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          array = %i[a b c]
          label = "everything"
          partial = new_partial(array, label)
          matcher = Spectator::Matchers::EmptyMatcher.new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end
      end
    end
  end
end
