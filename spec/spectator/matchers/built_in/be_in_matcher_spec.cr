require "../../../spec_helper"

alias BeInMatcher = Spectator::Matchers::BuiltIn::BeInMatcher

Spectator.describe BeInMatcher do
  describe "#matches?" do
    it "returns true if the value is in the list" do
      matcher = BeInMatcher.new([1, 2, 3])
      expect(matcher.matches?(2)).to be_true
    end

    it "returns false if the value is not in the list" do
      matcher = BeInMatcher.new([1, 2, 3])
      expect(matcher.matches?(4)).to be_false
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeInMatcher.new([1, 2, 3])
      expect(matcher.failure_message(4)).to eq <<-MESSAGE
        Expected: 4
        to be in: [1, 2, 3]
        MESSAGE
    end
  end

  describe "#negated_failure_message" do
    it "returns the negated failure message" do
      matcher = BeInMatcher.new([1, 2, 3])
      expect(matcher.negated_failure_message(2)).to eq <<-MESSAGE
            Expected: 2
        not to be in: [1, 2, 3]
        MESSAGE
    end
  end

  describe "#to_s" do
    it "returns the description" do
      matcher = BeInMatcher.new([1, 2, 3])
      expect(matcher.to_s).to eq("be in [1, 2, 3]")
    end
  end

  describe "DSL" do
    describe "`be_in`" do
      context "with `.to`" do
        it "matches if the value is in the list" do
          expect do
            expect(2).to be_in([1, 2, 3])
          end.to pass_check
        end

        it "does not match if the value is not in the list" do
          expect do
            expect(4).to be_in([1, 2, 3])
          end.to fail_check <<-MESSAGE
            Expected: 4
            to be in: [1, 2, 3]
            MESSAGE
        end
      end

      context "with `.not_to`" do
        it "matches if the value is not in the list" do
          expect do
            expect(4).not_to be_in([1, 2, 3])
          end.to pass_check
        end

        it "does not match if the value is in the list" do
          expect do
            expect(2).not_to be_in([1, 2, 3])
          end.to fail_check <<-MESSAGE
                Expected: 2
            not to be in: [1, 2, 3]
            MESSAGE
        end
      end
    end
  end
end
