require "../spec_helper"

describe Spectator::Matchers::ArrayMatcher do
  describe "#match" do
    context "returned MatchData" do
      context "with identical arrays" do
        describe "#matched?" do
          it "is true" do
            array = %i[a b c]
            partial = new_partial(array)
            matcher = Spectator::Matchers::ArrayMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        describe "#values" do
          context "expected" do
            it "is the expected array" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::ArrayMatcher.new(array)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(array)
            end
          end

          context "actual" do
            it "is the actual array" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::ArrayMatcher.new(array)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(array)
            end
          end
        end

        describe "#message" do
          it "contains the actual label" do
            array = %i[a b c]
            label = "everything"
            partial = new_partial(array, label)
            matcher = Spectator::Matchers::ArrayMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expected label" do
            array = %i[a b c]
            label = "everything"
            partial = new_partial(array)
            matcher = Spectator::Matchers::CaseMatcher.new(array, label)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = [1, 2, 3]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::CaseMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.message.should contain(array2.to_s)
            end
          end
        end

        describe "#negated_message" do
          it "contains the actual label" do
            array = %i[a b c]
            label = "everything"
            partial = new_partial(array, label)
            matcher = Spectator::Matchers::ArrayMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expected label" do
            array = %i[a b c]
            label = "everything"
            partial = new_partial(array)
            matcher = Spectator::Matchers::CaseMatcher.new(array, label)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = [1, 2, 3]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::CaseMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.negated_message.should contain(array2.to_s)
            end
          end
        end
      end

      context "with arrays differing in size" do
        describe "#matched?" do
          it "is false" do
            array1 = %i[a b c d e]
            array2 = %i[x y z]
            partial = new_partial(array1)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        describe "#values" do
          context "expected" do
            it "is the expected array" do
              array1 = %i[a b c d e]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(array2)
            end
          end

          context "actual" do
            it "is the actual array" do
              array1 = %i[a b c d e]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(array1)
            end
          end

          context "expected size" do
            it "is the expected size" do
              array1 = %i[a b c d e]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :"expected size")[:value].should eq(array2.size)
            end
          end

          context "actual size" do
            it "is the actual size" do
              array1 = %i[a b c d e]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :"actual size")[:value].should eq(array1.size)
            end
          end
        end

        describe "#message" do
          it "contains the actual label" do
            array1 = %i[a b c d e]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c d e]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c d e]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.message.should contain(array2.to_s)
            end
          end
        end

        describe "#negated_message" do
          it "mentions size" do
            array1 = %i[a b c d e]
            array2 = %i[x y z]
            partial = new_partial(array1)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain("size")
          end

          it "contains the actual label" do
            array1 = %i[a b c d e]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c d e]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c d e]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.negated_message.should contain(array2.to_s)
            end
          end
        end
      end

      context "with arrays differing in content" do
        describe "#matched?" do
          it "is false" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            partial = new_partial(array1)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        describe "#values" do
          context "expected" do
            it "is the expected array" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(array2)
            end
          end

          context "actual" do
            it "is the actual array" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(array1)
            end
          end

          context "expected element" do
            it "is the first mismatch" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :"expected element")[:value].should eq(array2.first)
            end
          end

          context "actual element" do
            it "is the first mismatch" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :"actual element")[:value].should eq(array1.first)
            end
          end

          context "index" do
            it "is the mismatched index" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :index)[:value].should eq(0)
            end
          end
        end

        describe "#message" do
          it "contains the actual label" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.message.should contain(array2.to_s)
            end
          end
        end

        describe "#negated_message" do
          it "mentions content" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            partial = new_partial(array1)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain("content")
          end

          it "contains the actual label" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::ArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.negated_message.should contain(array2.to_s)
            end
          end
        end
      end
    end
  end
end
