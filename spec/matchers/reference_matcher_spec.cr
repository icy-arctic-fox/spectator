require "../spec_helper"

describe Spectator::Matchers::ReferenceMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "with the same instance" do
          it "is true" do
            # Box is used because it is a reference type and doesn't override the == method.
            ref = Box.new([] of Int32)
            partial = new_partial(ref)
            matcher = Spectator::Matchers::ReferenceMatcher.new(ref)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with different instances" do
          context "with same contents" do
            it "is false" do
              array1 = [1, 2, 3]
              array2 = [1, 2, 3]
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ReferenceMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "with a duplicated instance" do
            it "is false" do
              array1 = [1, 2, 3]
              array2 = array1.dup
              partial = new_partial(array1)
              matcher = Spectator::Matchers::ReferenceMatcher.new(array2)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "with the same type" do
            it "is false" do
              obj1 = "foo"
              obj2 = "bar"
              partial = new_partial(obj1)
              matcher = Spectator::Matchers::ReferenceMatcher.new(obj2)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "with a different type" do
            it "is false" do
              obj1 = "foobar"
              obj2 = [1, 2, 3]
              partial = new_partial(obj1)
              matcher = Spectator::Matchers::ReferenceMatcher.new(obj2)
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
            matcher = Spectator::Matchers::ReferenceMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :expected)[:value].should eq(expected)
          end
        end

        context "actual" do
          it "is the actual value" do
            actual = "foobar"
            expected = /foo/
            partial = new_partial(actual)
            matcher = Spectator::Matchers::ReferenceMatcher.new(expected)
            match_data = matcher.match(partial)
            match_data_value_sans_prefix(match_data.values, :actual)[:value].should eq(actual)
          end
        end
      end

      describe "#message" do
        it "contains the actual label" do
          value = "foobar"
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::ReferenceMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          value = "foobar"
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::ReferenceMatcher.new(value, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            obj1 = "foo"
            obj2 = "bar"
            partial = new_partial(obj1)
            matcher = Spectator::Matchers::ReferenceMatcher.new(obj2)
            match_data = matcher.match(partial)
            match_data.message.should contain(obj2.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          value = "foobar"
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::ReferenceMatcher.new(value)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          value = "foobar"
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::ReferenceMatcher.new(value, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            obj1 = "foo"
            obj2 = "bar"
            partial = new_partial(obj1)
            matcher = Spectator::Matchers::ReferenceMatcher.new(obj2)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(obj2.to_s)
          end
        end
      end
    end
  end
end
