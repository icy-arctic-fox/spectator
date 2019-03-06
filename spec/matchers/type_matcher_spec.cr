require "../spec_helper"

describe Spectator::Matchers::TypeMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "with the same type" do
          it "is true" do
            value = "foobar"
            partial = new_partial(value)
            matcher = Spectator::Matchers::TypeMatcher(String).new
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with a different type" do
          it "is false" do
            value = "foobar"
            partial = new_partial(value)
            matcher = Spectator::Matchers::TypeMatcher(Int32).new
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        context "with a parent type" do
          it "is true" do
            value = IO::Memory.new
            partial = new_partial(value)
            matcher = Spectator::Matchers::TypeMatcher(IO).new
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with a child type" do
          it "is false" do
            value = Exception.new("foobar")
            partial = new_partial(value)
            matcher = Spectator::Matchers::TypeMatcher(ArgumentError).new
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        context "with a mix-in" do
          it "is true" do
            value = %i[a b c]
            partial = new_partial(value)
            matcher = Spectator::Matchers::TypeMatcher(Enumerable(Symbol)).new
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end
      end

      describe "#values" do
        context "expected" do
          it "is the expected type name" do
            value = %i[a b c]
            partial = new_partial(value)
            matcher = Spectator::Matchers::TypeMatcher(String).new
            match_data = matcher.match(partial)
            match_data.values[:expected].should eq(String)
          end
        end

        context "actual" do
          it "is the actual type name" do
            value = %i[a b c]
            partial = new_partial(value)
            matcher = Spectator::Matchers::TypeMatcher(String).new
            match_data = matcher.match(partial)
            match_data.values[:actual].should eq(typeof(value))
          end
        end
      end

      describe "#message" do
        it "contains the actual label" do
          value = 42
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::TypeMatcher(String).new
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected type" do
          partial = new_partial(42)
          matcher = Spectator::Matchers::TypeMatcher(String).new
          match_data = matcher.match(partial)
          match_data.message.should contain("String")
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          value = 42
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::TypeMatcher(String).new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected type" do
          partial = new_partial(42)
          matcher = Spectator::Matchers::TypeMatcher(String).new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("String")
        end
      end
    end
  end
end
