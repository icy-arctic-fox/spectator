require "../spec_helper"

describe Spectator::Matchers::RegexMatcher do
  describe "#match" do
    it "compares using #=~" do
      spy = SpySUT.new
      partial = new_partial(spy)
      matcher = Spectator::Matchers::RegexMatcher.new(/foobar/)
      matcher.match(partial)
      spy.match_call_count.should be > 0
    end

    context "returned MatchData" do
      describe "#matched?" do
        context "with a matching pattern" do
          it "is true" do
            value = "foobar"
            pattern = /foo/
            partial = new_partial(value)
            matcher = Spectator::Matchers::RegexMatcher.new(pattern)
            match_data = matcher.match(partial)
            match_data.matched?.should be_true
          end
        end

        context "with a non-matching pattern" do
          it "is false" do
            value = "foo"
            pattern = /bar/
            partial = new_partial(value)
            matcher = Spectator::Matchers::RegexMatcher.new(pattern)
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end
      end

      describe "#values" do
        context "expected" do
          it "is the expected value" do
            value = "foo"
            pattern = /bar/
            partial = new_partial(value)
            matcher = Spectator::Matchers::RegexMatcher.new(pattern)
            match_data = matcher.match(partial)
            match_data.values[:expected].value.should eq(pattern)
          end
        end

        context "actual" do
          it "is the actual value" do
            value = "foo"
            pattern = /bar/
            partial = new_partial(value)
            matcher = Spectator::Matchers::RegexMatcher.new(pattern)
            match_data = matcher.match(partial)
            match_data.values[:actual].should eq(value)
          end
        end
      end

      describe "#message" do
        it "mentions =~" do
          value = "foobar"
          pattern = /foo/
          partial = new_partial(value)
          matcher = Spectator::Matchers::RegexMatcher.new(pattern)
          match_data = matcher.match(partial)
          match_data.message.should contain("=~")
        end

        it "contains the actual label" do
          value = "foobar"
          label = "different"
          pattern = /foo/
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::RegexMatcher.new(pattern)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          value = "foobar"
          label = "different"
          pattern = /foo/
          partial = new_partial(value)
          matcher = Spectator::Matchers::RegexMatcher.new(pattern, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            value = "foobar"
            pattern = /foo/
            partial = new_partial(value)
            matcher = Spectator::Matchers::RegexMatcher.new(pattern)
            match_data = matcher.match(partial)
            match_data.message.should contain(pattern.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "mentions =~" do
          value = "foobar"
          pattern = /foo/
          partial = new_partial(value)
          matcher = Spectator::Matchers::RegexMatcher.new(pattern)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("=~")
        end

        it "contains the actual label" do
          value = "foobar"
          label = "different"
          pattern = /foo/
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::RegexMatcher.new(pattern)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          value = "foobar"
          label = "different"
          pattern = /foo/
          partial = new_partial(value)
          matcher = Spectator::Matchers::RegexMatcher.new(pattern, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            value = "foobar"
            pattern = /foo/
            partial = new_partial(value)
            matcher = Spectator::Matchers::RegexMatcher.new(pattern)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(pattern.to_s)
          end
        end
      end
    end
  end
end
