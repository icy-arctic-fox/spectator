require "../spec_helper"

private struct FakeKeySet
  def has_key?(key)
    true
  end
end

describe Spectator::Matchers::HaveKeyMatcher do
  describe "#match" do
    context "returned MatchData" do
      describe "#matched?" do
        context "against a Hash" do
          context "with an existing key" do
            it "is true" do
              hash = Hash{"foo" => "bar"}
              key = "foo"
              partial = new_partial(hash)
              matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "with a non-existent key" do
            it "is false" do
              hash = Hash{"foo" => "bar"}
              key = "baz"
              partial = new_partial(hash)
              matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end
        end

        context "against a NamedTuple" do
          context "with an existing key" do
            it "is true" do
              tuple = {foo: "bar"}
              key = :foo
              partial = new_partial(tuple)
              matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "with a non-existent key" do
            it "is false" do
              tuple = {foo: "bar"}
              key = :baz
              partial = new_partial(tuple)
              matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end
        end
      end

      describe "#values" do
        context "key" do
          it "is the expected key" do
            tuple = {foo: "bar"}
            key = :baz
            partial = new_partial(tuple)
            matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
            match_data = matcher.match(partial)
            match_data.values[:key].should eq(key)
          end
        end

        context "actual" do
          context "when #keys is available" do
            it "is the list of keys" do
              tuple = {foo: "bar"}
              key = :baz
              partial = new_partial(tuple)
              matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
              match_data = matcher.match(partial)
              match_data.values[:actual].should eq(tuple.keys)
            end
          end

          context "when #keys isn't available" do
            it "is the actual value" do
              actual = FakeKeySet.new
              key = :baz
              partial = new_partial(actual)
              matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
              match_data = matcher.match(partial)
              match_data.values[:actual].should eq(actual)
            end
          end
        end
      end

      describe "#message" do
        it "contains the actual label" do
          tuple = {foo: "bar"}
          key = :foo
          label = "blah"
          partial = new_partial(tuple, label)
          matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          tuple = {foo: "bar"}
          key = :foo
          label = "blah"
          partial = new_partial(tuple)
          matcher = Spectator::Matchers::HaveKeyMatcher.new(key, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when the expected label is omitted" do
          it "contains the stringified key" do
            tuple = {foo: "bar"}
            key = :foo
            partial = new_partial(tuple)
            matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
            match_data = matcher.match(partial)
            match_data.message.should contain(key.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          tuple = {foo: "bar"}
          key = :foo
          label = "blah"
          partial = new_partial(tuple, label)
          matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          tuple = {foo: "bar"}
          key = :foo
          label = "blah"
          partial = new_partial(tuple)
          matcher = Spectator::Matchers::HaveKeyMatcher.new(key, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when the expected label is omitted" do
          it "contains the stringified key" do
            tuple = {foo: "bar"}
            key = :foo
            partial = new_partial(tuple)
            matcher = Spectator::Matchers::HaveKeyMatcher.new(key)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(key.to_s)
          end
        end
      end
    end
  end
end
