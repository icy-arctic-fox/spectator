require "../../../spec_helper"

struct NegativeObject
  getter? negative : Bool

  def initialize(@negative : Bool = true)
  end
end

alias BeNegativeMatcher = Spectator::Matchers::BuiltIn::BeNegativeMatcher

Spectator.describe BeNegativeMatcher do
  describe "#matches?" do
    it "returns true if the object is negative" do
      matcher = BeNegativeMatcher.new
      expect(matcher.matches?(NegativeObject.new)).to be_true
    end

    it "returns false if the object is not negative" do
      matcher = BeNegativeMatcher.new
      expect(matcher.matches?(NegativeObject.new(false))).to be_false
    end

    context "with a Float" do
      it "returns true if the value is negative" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(-1.0)).to be_true
      end

      it "returns false if the value is positive" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(1.0)).to be_false
      end

      it "returns false if the value is zero" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(0.0)).to be_false
      end

      it "returns false if the value is positive infinity" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(Float64::INFINITY)).to be_false
      end

      it "returns true if the value is negative infinity" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(-Float64::INFINITY)).to be_true
      end

      it "returns false if the value is NaN" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(Float64::NAN)).to be_false
      end
    end

    context "with an Int" do
      it "returns true if the value is negative" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(-1)).to be_true
      end

      it "returns false if the value is positive" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(1)).to be_false
      end

      it "returns false if the value is zero" do
        matcher = BeNegativeMatcher.new
        expect(matcher.matches?(0)).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeNegativeMatcher.new
      expect(matcher.failure_message(1.0)).to eq("Expected 1.0 to be negative")
    end
  end

  describe "#negated_failure_message" do
    it "returns the negated failure message" do
      matcher = BeNegativeMatcher.new
      expect(matcher.negated_failure_message(-1.0)).to eq("Expected -1.0 not to be negative")
    end
  end

  describe "#to_s" do
    it "returns the description" do
      matcher = BeNegativeMatcher.new
      expect(matcher.to_s).to eq("be negative")
    end
  end

  describe "DSL" do
    describe "`be_negative`" do
      context "with `.to`" do
        it "matches if the object is negative" do
          expect do
            expect(NegativeObject.new).to be_negative
          end.to pass_check
        end

        it "does not match if the object is not negative" do
          object = NegativeObject.new(false)
          expect do
            expect(object).to be_negative
          end.to fail_check("Expected #{object.pretty_inspect} to be negative")
        end

        context "with a Float" do
          it "matches if the value is negative" do
            expect do
              expect(-1.0).to be_negative
            end.to pass_check
          end

          it "does not match if the value is positive" do
            expect do
              expect(1.0).to be_negative
            end.to fail_check("Expected 1.0 to be negative")
          end

          it "does not match if the value is zero" do
            expect do
              expect(0.0).to be_negative
            end.to fail_check("Expected 0.0 to be negative")
          end

          it "does not match if the value is positive infinity" do
            expect do
              expect(Float64::INFINITY).to be_negative
            end.to fail_check("Expected Infinity to be negative")
          end

          it "matches if the value is negative infinity" do
            expect do
              expect(-Float64::INFINITY).to be_negative
            end.to pass_check
          end

          it "does not match if the value is NaN" do
            expect do
              expect(Float64::NAN).to be_negative
            end.to fail_check("Expected NaN to be negative")
          end
        end

        context "with an Int" do
          it "matches if the value is negative" do
            expect do
              expect(-1).to be_negative
            end.to pass_check
          end

          it "does not match if the value is positive" do
            expect do
              expect(1).to be_negative
            end.to fail_check("Expected 1 to be negative")
          end

          it "does not match if the value is zero" do
            expect do
              expect(0).to be_negative
            end.to fail_check("Expected 0 to be negative")
          end
        end
      end

      context "with `.not_to`" do
        it "matches if the object is negative" do
          object = NegativeObject.new
          expect do
            expect(object).not_to be_negative
          end.to fail_check("Expected #{object.pretty_inspect} not to be negative")
        end

        it "does not match if the object is not negative" do
          expect do
            expect(NegativeObject.new(false)).not_to be_negative
          end.to pass_check
        end

        context "with a Float" do
          it "does not match if the value is negative" do
            expect do
              expect(-1.0).not_to be_negative
            end.to fail_check("Expected -1.0 not to be negative")
          end

          it "matches if the value is positive" do
            expect do
              expect(1.0).not_to be_negative
            end.to pass_check
          end

          it "matches if the value is zero" do
            expect do
              expect(0.0).not_to be_negative
            end.to pass_check
          end

          it "matches if the value is positive infinity" do
            expect do
              expect(Float64::INFINITY).not_to be_negative
            end.to pass_check
          end

          it "does not match if the value is negative infinity" do
            expect do
              expect(-Float64::INFINITY).not_to be_negative
            end.to fail_check("Expected -Infinity not to be negative")
          end

          it "matches if the value is NaN" do
            expect do
              expect(Float64::NAN).not_to be_negative
            end.to pass_check
          end
        end

        context "with an Int" do
          it "does not match if the value is negative" do
            expect do
              expect(-1).not_to be_negative
            end.to fail_check("Expected -1 not to be negative")
          end

          it "matches if the value is positive" do
            expect do
              expect(1).not_to be_negative
            end.to pass_check
          end

          it "matches if the value is zero" do
            expect do
              expect(0).not_to be_negative
            end.to pass_check
          end
        end
      end
    end
  end
end
