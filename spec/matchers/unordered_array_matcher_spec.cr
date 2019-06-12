require "../spec_helper"

describe Spectator::Matchers::UnorderedArrayMatcher do
  describe "#match" do
    context "returned MatchData" do
      context "with identical arrays" do
        describe "#matched?" do
          it "is true" do
            array = %i[a b c]
            partial = new_partial(array)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        describe "#values" do
          context "expected" do
            it "is the expected array" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(array)
            end
          end

          context "actual" do
            it "is the actual array" do
              array = %i[a b c]
              partial = new_partial(array)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array)
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
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expected label" do
            array = %i[a b c]
            label = "everything"
            partial = new_partial(array)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array, label)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = [1, 2, 3]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
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
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expected label" do
            array = %i[a b c]
            label = "everything"
            partial = new_partial(array)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array, label)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = [1, 2, 3]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.negated_message.should contain(array2.to_s)
            end
          end
        end
      end

      context "with identical unordered arrays" do
        describe "#matched?" do
          it "is true" do
            array1 = %i[a b c]
            array2 = %i[c a b]
            partial = new_partial(array1)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        describe "#values" do
          context "expected" do
            it "is the expected array" do
              array1 = %i[a b c]
              array2 = %i[c a b]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(array2)
            end
          end

          context "actual" do
            it "is the actual array" do
              array1 = %i[a b c]
              array2 = %i[c a b]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(array1)
            end
          end
        end

        describe "#message" do
          it "contains the actual label" do
            array1 = %i[a b c]
            array2 = %i[c a b]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c]
            array2 = %i[c a b]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = %i[c a b]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.message.should contain(array2.to_s)
            end
          end
        end

        describe "#negated_message" do
          it "contains the actual label" do
            array1 = %i[a b c]
            array2 = %i[c a b]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c]
            array2 = %i[c a b]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = %i[c a b]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
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
            array2 = %i[a c e f]
            partial = new_partial(array1)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        describe "#values" do
          context "expected" do
            it "is the expected array" do
              array1 = %i[a b c d e]
              array2 = %i[a c e f]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(array2)
            end
          end

          context "actual" do
            it "is the actual array" do
              array1 = %i[a b c d e]
              array2 = %i[a c e f]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(array1)
            end
          end

          context "missing" do
            it "is the missing items" do
              array1 = %i[a b c d e]
              array2 = %i[a c e f]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              missing = match_data_value_sans_prefix(match_data.values, :missing)[:value].as(typeof(array2))
              missing.should contain(:f)
            end
          end

          context "extra" do
            it "is the extra items" do
              array1 = %i[a b c d e]
              array2 = %i[a c e f]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              extra = match_data_value_sans_prefix(match_data.values, :extra)[:value].as(typeof(array1))
              extra.should contain(:b)
              extra.should contain(:d)
            end
          end
        end

        describe "#message" do
          it "contains the actual label" do
            array1 = %i[a b c d e]
            array2 = %i[a c e f]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c d e]
            array2 = %i[a c e f]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c d e]
              array2 = %i[a c e f]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.message.should contain(array2.to_s)
            end
          end
        end

        describe "#negated_message" do
          it "contains the actual label" do
            array1 = %i[a b c d e]
            array2 = %i[a c e f]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c d e]
            array2 = %i[a c e f]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c d e]
              array2 = %i[a c e f]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
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
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
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
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(array2)
            end
          end

          context "actual" do
            it "is the actual array" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(array1)
            end
          end

          context "missing" do
            it "is the missing items" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              missing = match_data_value_sans_prefix(match_data.values, :missing)[:value].as(typeof(array2))
              missing.should contain(:x)
              missing.should contain(:y)
              missing.should contain(:z)
            end
          end

          context "extra" do
            it "is the extra items" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              extra = match_data_value_sans_prefix(match_data.values, :extra)[:value].as(typeof(array1))
              extra.should contain(:a)
              extra.should contain(:b)
              extra.should contain(:c)
            end
          end
        end

        describe "#message" do
          it "contains the actual label" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
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
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain("content")
          end

          it "contains the actual label" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1, label)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          it "contains the expected label" do
            array1 = %i[a b c]
            array2 = %i[x y z]
            label = "everything"
            partial = new_partial(array1)
            matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2, label)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(label)
          end

          context "when expected label is omitted" do
            it "contains stringified form of expected array" do
              array1 = %i[a b c]
              array2 = %i[x y z]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::UnorderedArrayMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.negated_message.should contain(array2.to_s)
            end
          end
        end
      end
    end
  end
end
