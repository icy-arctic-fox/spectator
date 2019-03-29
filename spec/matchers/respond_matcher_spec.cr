require "../spec_helper"

describe Spectator::Matchers::RespondMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "one method" do
          context "with a responding method" do
            it "is true" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil)).new
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "against a non-responding method" do
            it "is false" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::RespondMatcher(NamedTuple(downcase: Nil)).new
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end
        end

        context "multiple methods" do
          context "with one responding method" do
            it "is false" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil, downcase: Nil)).new
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "with all responding methods" do
            it "is true" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil, to_a: Nil)).new
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "with no responding methods" do
            it "is false" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::RespondMatcher(NamedTuple(downcase: Nil, upcase: Nil)).new
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end
        end
      end

      describe "#values" do
        it "contains a key for each expected method" do
          array = %i[a b c]
          partial = new_partial(array)
          matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil, downcase: Nil)).new
          match_data = matcher.match(partial)
          match_data_has_key?(match_data.values, :"responds to #size").should be_true
          match_data_has_key?(match_data.values, :"responds to #downcase").should be_true
        end

        it "has the actual values" do
          array = %i[a b c]
          partial = new_partial(array)
          matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil, downcase: Nil)).new
          match_data = matcher.match(partial)
          match_data_value_sans_prefix(match_data.values, :"responds to #size")[:value].should be_true
          match_data_value_sans_prefix(match_data.values, :"responds to #downcase")[:value].should be_false
        end
      end

      describe "#message" do
        it "contains the actual label" do
          value = "foobar"
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil, downcase: Nil)).new
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the method names" do
          value = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil, downcase: Nil)).new
          match_data = matcher.match(partial)
          match_data.message.should contain("#size")
          match_data.message.should contain("#downcase")
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          value = "foobar"
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil, downcase: Nil)).new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the method names" do
          value = "foobar"
          partial = new_partial(value)
          matcher = Spectator::Matchers::RespondMatcher(NamedTuple(size: Nil, downcase: Nil)).new
          match_data = matcher.match(partial)
          match_data.message.should contain("#size")
          match_data.negated_message.should contain("#downcase")
        end
      end
    end
  end
end
