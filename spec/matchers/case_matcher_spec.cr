require "../spec_helper"

describe Spectator::Matchers::CaseMatcher do
  describe "#match" do
    it "compares using #===" do
      spy = SpySUT.new
      partial = new_partial(42)
      matcher = Spectator::Matchers::CaseMatcher.new(spy)
      matcher.match(partial)
      spy.case_eq_call_count.should be > 0
    end

    context "returned MatchData" do
      describe "#matched?" do
        context "with identical values" do
          it "is true" do
            value = 42
            partial = new_partial(value)
            matcher = Spectator::Matchers::CaseMatcher.new(value)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with different values" do
          it "is false" do
            value1 = 42
            value2 = 777
            partial = new_partial(value1)
            matcher = Spectator::Matchers::CaseMatcher.new(value2)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        context "with the same instance" do
          it "is true" do
            # Box is used because it is a reference type and doesn't override the == method.
            ref = Box.new([] of Int32)
            partial = new_partial(ref)
            matcher = Spectator::Matchers::CaseMatcher.new(ref)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with different instances" do
          context "with same contents" do
            it "is true" do
              array1 = [1, 2, 3]
              array2 = [1, 2, 3]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::CaseMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "with different contents" do
            it "is false" do
              array1 = [1, 2, 3]
              array2 = [4, 5, 6]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::CaseMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "with the same type" do
            it "is true" do
              value1 = "foobar"
              value2 = String
              partial = new_partial(value1)
              matcher = Spectator::Matchers::CaseMatcher.new(value2)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "with a different type" do
            it "is false" do
              value1 = "foobar"
              value2 = Array
              partial = new_partial(value1)
              matcher = Spectator::Matchers::CaseMatcher.new(value2)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end
        end
      end

      describe "#values" do
        context "expected" do
          it "is the expected value" do
            actual = "foobar"
            expected = /foo/
            partial = new_partial(actual)
            matcher = Spectator::Matchers::CaseMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(expected)
          end
        end

        context "actual" do
          it "is the actual value" do
            actual = "foobar"
            expected = /foo/
            partial = new_partial(actual)
            matcher = Spectator::Matchers::CaseMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(actual)
          end
        end
      end

      describe "#message" do
        it "mentions ===" do
          value = 42
          partial = new_partial(value)
          matcher = Spectator::Matchers::CaseMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.message.should contain("===")
        end

        it "contains the actual label" do
          value = 42
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::CaseMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          value = 42
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::CaseMatcher.new(value, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            value1 = 42
            value2 = 777
            partial = new_partial(value1)
            matcher = Spectator::Matchers::CaseMatcher.new(value2)
            match_data = matcher.match(partial)
            match_data.message.should contain(value2.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "mentions ===" do
          value = 42
          partial = new_partial(value)
          matcher = Spectator::Matchers::CaseMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("===")
        end

        it "contains the actual label" do
          value = 42
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::CaseMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          value = 42
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::CaseMatcher.new(value, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            value1 = 42
            value2 = 777
            partial = new_partial(value1)
            matcher = Spectator::Matchers::CaseMatcher.new(value2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(value2.to_s)
          end
        end
      end
    end
  end
end
