require "../../../spec_helper"

alias BeFalsyMatcher = Spectator::Matchers::BuiltIn::BeFalsyMatcher

Spectator.describe BeFalsyMatcher do
  describe "#matches?" do
    it "returns true if the value is false" do
      matcher = BeFalsyMatcher.new
      expect(matcher.matches?(false)).to be_true
    end

    it "returns true if the value is nil" do
      matcher = BeFalsyMatcher.new
      expect(matcher.matches?(nil)).to be_true
    end

    it "returns false if the value is truthy" do
      matcher = BeFalsyMatcher.new
      expect(matcher.matches?(42)).to be_false
    end

    it "returns false if the value is true" do
      matcher = BeFalsyMatcher.new
      expect(matcher.matches?(true)).to be_false
    end

    it "returns false if the value is zero" do
      matcher = BeFalsyMatcher.new
      expect(matcher.matches?(0)).to be_false
    end

    it "returns false if the value is an empty string" do
      matcher = BeFalsyMatcher.new
      expect(matcher.matches?("")).to be_false
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeFalsyMatcher.new
      expect(matcher.failure_message("foo")).to eq("Expected \"foo\" to be falsy")
    end
  end

  describe "#negated_failure_message" do
    it "returns the negative failure message" do
      matcher = BeFalsyMatcher.new
      expect(matcher.negated_failure_message(nil)).to eq("Expected nil to be truthy")
    end
  end

  context "DSL" do
    describe "be_falsy" do
      context "with .to" do
        it "matches if the value is false" do
          expect do
            expect(false).to be_falsy
          end.to pass_check
        end

        it "matches if the value is nil" do
          expect do
            expect(nil).to be_falsy
          end.to pass_check
        end

        it "does not match if the value is truthy" do
          expect do
            expect(42).to be_falsy
          end.to fail_check("Expected 42 to be falsy")
        end

        it "does not match if the value is true" do
          expect do
            expect(true).to be_falsy
          end.to fail_check("Expected true to be falsy")
        end

        it "does not match if the value is zero" do
          expect do
            expect(0).to be_falsy
          end.to fail_check("Expected 0 to be falsy")
        end

        it "does not match if the value is an empty string" do
          expect do
            expect("").to be_falsy
          end.to fail_check("Expected \"\" to be falsy")
        end
      end

      context "with .not_to" do
        it "does not match if the value is false" do
          expect do
            expect(false).not_to be_falsy
          end.to fail_check("Expected false to be truthy")
        end

        it "does not match if the value is nil" do
          expect do
            expect(nil).not_to be_falsy
          end.to fail_check("Expected nil to be truthy")
        end

        it "matches if the value is truthy" do
          expect do
            expect(42).not_to be_falsy
          end.to pass_check
        end

        it "matches if the value is true" do
          expect do
            expect(true).not_to be_falsy
          end.to pass_check
        end

        it "matches if the value is zero" do
          expect do
            expect(0).not_to be_falsy
          end.to pass_check
        end

        it "matches if the value is an empty string" do
          expect do
            expect("").not_to be_falsy
          end.to pass_check
        end
      end
    end

    describe "be_falsey" do
      context "with .to" do
        it "matches if the value is false" do
          expect do
            expect(false).to be_falsey
          end.to pass_check
        end

        it "matches if the value is nil" do
          expect do
            expect(nil).to be_falsey
          end.to pass_check
        end

        it "does not match if the value is truthy" do
          expect do
            expect(42).to be_falsey
          end.to fail_check("Expected 42 to be falsy")
        end

        it "does not match if the value is true" do
          expect do
            expect(true).to be_falsey
          end.to fail_check("Expected true to be falsy")
        end

        it "does not match if the value is zero" do
          expect do
            expect(0).to be_falsey
          end.to fail_check("Expected 0 to be falsy")
        end

        it "does not match if the value is an empty string" do
          expect do
            expect("").to be_falsey
          end.to fail_check("Expected \"\" to be falsy")
        end
      end

      context "with .not_to" do
        it "does not match if the value is false" do
          expect do
            expect(false).not_to be_falsey
          end.to fail_check("Expected false to be truthy")
        end

        it "does not match if the value is nil" do
          expect do
            expect(nil).not_to be_falsey
          end.to fail_check("Expected nil to be truthy")
        end

        it "matches if the value is truthy" do
          expect do
            expect(42).not_to be_falsey
          end.to pass_check
        end

        it "matches if the value is true" do
          expect do
            expect(true).not_to be_falsey
          end.to pass_check
        end

        it "matches if the value is zero" do
          expect do
            expect(0).not_to be_falsey
          end.to pass_check
        end

        it "matches if the value is an empty string" do
          expect do
            expect("").not_to be_falsey
          end.to pass_check
        end
      end
    end
  end
end
