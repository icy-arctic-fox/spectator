require "../../../spec_helper"

alias BeCloseMatcher = Spectator::Matchers::BuiltIn::BeCloseMatcher

Spectator.describe BeCloseMatcher do
  describe "#matches?" do
    it "returns true if the value is within the delta" do
      matcher = BeCloseMatcher.new(1.0, 0.1)
      expect(matcher.matches?(1.01)).to be_true
    end

    it "returns false if the value is outside the delta" do
      matcher = BeCloseMatcher.new(1.0, 0.1)
      expect(matcher.matches?(1.11)).to be_false
    end

    it "returns true if the values are equal" do
      matcher = BeCloseMatcher.new(1.0, 0.1)
      expect(matcher.matches?(1.0)).to be_true
    end

    it "returns true if the value is at the minimum" do
      matcher = BeCloseMatcher.new(1.0, 0.1)
      expect(matcher.matches?(0.9)).to be_true
    end

    it "returns true if the value is at the maximum" do
      matcher = BeCloseMatcher.new(1.0, 0.1)
      expect(matcher.matches?(1.1)).to be_true
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeCloseMatcher.new(1.0, 0.1)
      expect(matcher.failure_message(1.11)).to eq <<-MESSAGE
            Expected: 1.11
        to be within: 1.0 ± 0.1
        MESSAGE
    end
  end

  describe "#negated_failure_message" do
    it "returns the negative failure message" do
      matcher = BeCloseMatcher.new(1.0, 0.1)
      expect(matcher.negated_failure_message(1.01)).to eq <<-MESSAGE
             Expected: 1.01
        to be outside: 1.0 ± 0.1
        MESSAGE
    end
  end

  describe "DSL" do
    context "with .to" do
      it "matches if the value is within the delta" do
        expect do
          expect(1.01).to be_close(1.0, delta: 0.1)
        end.to pass_check
      end

      it "does not match if the value is outside the delta" do
        expect do
          expect(1.11).to be_close(1.0, delta: 0.1)
        end.to fail_check <<-MESSAGE
              Expected: 1.11
          to be within: 1.0 ± 0.1
          MESSAGE
      end

      it "matches if the values are equal" do
        expect do
          expect(1.0).to be_close(1.0, delta: 0.1)
        end.to pass_check
      end

      it "matches if the value is at the minimum" do
        expect do
          expect(0.9).to be_close(1.0, delta: 0.1)
        end.to pass_check
      end

      it "matches if the value is at the maximum" do
        expect do
          expect(1.1).to be_close(1.0, delta: 0.1)
        end.to pass_check
      end
    end

    context "with .not_to" do
      it "does not match if the value is within the delta" do
        expect do
          expect(1.01).not_to be_close(1.0, delta: 0.1)
        end.to fail_check <<-MESSAGE
               Expected: 1.01
          to be outside: 1.0 ± 0.1
          MESSAGE
      end

      it "matches if the value is outside the delta" do
        expect do
          expect(1.11).not_to be_close(1.0, delta: 0.1)
        end.to pass_check
      end

      it "does not match if the values are equal" do
        expect do
          expect(1.0).not_to be_close(1.0, delta: 0.1)
        end.to fail_check <<-MESSAGE
               Expected: 1.0
          to be outside: 1.0 ± 0.1
          MESSAGE
      end

      it "does not match if the value is at the minimum" do
        expect do
          expect(0.9).not_to be_close(1.0, delta: 0.1)
        end.to fail_check <<-MESSAGE
               Expected: 0.9
          to be outside: 1.0 ± 0.1
          MESSAGE
      end

      it "does not match if the value is at the maximum" do
        expect do
          expect(1.1).not_to be_close(1.0, delta: 0.1)
        end.to fail_check <<-MESSAGE
               Expected: 1.1
          to be outside: 1.0 ± 0.1
          MESSAGE
      end
    end
  end
end
