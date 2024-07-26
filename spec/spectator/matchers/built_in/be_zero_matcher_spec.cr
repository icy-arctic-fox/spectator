require "../../../spec_helper"

struct ZeroObject
  getter? zero : Bool

  def initialize(@zero : Bool = true)
  end
end

alias BeZeroMatcher = Spectator::Matchers::BuiltIn::BeZeroMatcher

Spectator.describe BeZeroMatcher do
  describe "#matches?" do
    it "returns true if the object is zero" do
      matcher = BeZeroMatcher.new
      expect(matcher.matches?(ZeroObject.new)).to be_true
    end

    it "returns false if the object is not zero" do
      matcher = BeZeroMatcher.new
      expect(matcher.matches?(ZeroObject.new(false))).to be_false
    end

    context "with a Float" do
      it "returns true if the value is zero" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(0.0)).to be_true
      end

      it "returns false if the value is positive" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(1.0)).to be_false
      end

      it "returns false if the value is negative" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(-1.0)).to be_false
      end

      it "returns false if the value is positive infinity" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(Float64::INFINITY)).to be_false
      end

      it "returns false if the value is negative infinity" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(-Float64::INFINITY)).to be_false
      end

      it "returns false if the value is NaN" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(Float64::NAN)).to be_false
      end
    end

    context "with an Int" do
      it "returns true if the value is zero" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(0)).to be_true
      end

      it "returns false if the value is positive" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(1)).to be_false
      end

      it "returns false if the value is negative" do
        matcher = BeZeroMatcher.new
        expect(matcher.matches?(-1)).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeZeroMatcher.new
      expect(matcher.failure_message(-1.0)).to eq("Expected -1.0 to be zero")
    end
  end

  describe "#negated_failure_message" do
    it "returns the negated failure message" do
      matcher = BeZeroMatcher.new
      expect(matcher.negated_failure_message(0.0)).to eq("Expected 0.0 not to be zero")
    end
  end

  describe "DSL" do
    describe "`be_zero`" do
      context "with `.to`" do
        it "matches if the object is zero" do
          expect do
            expect(ZeroObject.new).to be_zero
          end.to pass_check
        end

        it "does not match if the object is not zero" do
          object = ZeroObject.new(false)
          expect do
            expect(object).to be_zero
          end.to fail_check("Expected #{object.pretty_inspect} to be zero")
        end

        context "with a Float" do
          it "matches if the value is zero" do
            expect do
              expect(0.0).to be_zero
            end.to pass_check
          end

          it "does not match if the value is positive" do
            expect do
              expect(1.0).to be_zero
            end.to fail_check("Expected 1.0 to be zero")
          end

          it "does not match if the value is negative" do
            expect do
              expect(-1.0).to be_zero
            end.to fail_check("Expected -1.0 to be zero")
          end

          it "does not match if the value is positive infinity" do
            expect do
              expect(Float64::INFINITY).to be_zero
            end.to fail_check("Expected Infinity to be zero")
          end

          it "does not match if the value is negative infinity" do
            expect do
              expect(-Float64::INFINITY).to be_zero
            end.to fail_check("Expected -Infinity to be zero")
          end

          it "does not match if the value is NaN" do
            expect do
              expect(Float64::NAN).to be_zero
            end.to fail_check("Expected NaN to be zero")
          end
        end

        context "with an Int" do
          it "matches if the value is zero" do
            expect do
              expect(0).to be_zero
            end.to pass_check
          end

          it "does not match if the value is positive" do
            expect do
              expect(1).to be_zero
            end.to fail_check("Expected 1 to be zero")
          end

          it "does not match if the value is negative" do
            expect do
              expect(-1).to be_zero
            end.to fail_check("Expected -1 to be zero")
          end
        end
      end

      context "with `.not_to`" do
        it "does not match if the object is zero" do
          object = ZeroObject.new
          expect do
            expect(object).not_to be_zero
          end.to fail_check("Expected #{object.pretty_inspect} not to be zero")
        end

        it "matches if the object is not zero" do
          expect do
            expect(ZeroObject.new(false)).not_to be_zero
          end.to pass_check
        end

        context "with a Float" do
          it "does not match if the value is zero" do
            expect do
              expect(0.0).not_to be_zero
            end.to fail_check("Expected 0.0 not to be zero")
          end

          it "matches if the value is positive" do
            expect do
              expect(1.0).not_to be_zero
            end.to pass_check
          end

          it "matches if the value is negative" do
            expect do
              expect(-1.0).not_to be_zero
            end.to pass_check
          end

          it "matches if the value is positive infinity" do
            expect do
              expect(Float64::INFINITY).not_to be_zero
            end.to pass_check
          end

          it "matches if the value is negative infinity" do
            expect do
              expect(-Float64::INFINITY).not_to be_zero
            end.to pass_check
          end

          it "matches if the value is NaN" do
            expect do
              expect(Float64::NAN).not_to be_zero
            end.to pass_check
          end
        end

        context "with an Int" do
          it "does not match if the value is zero" do
            expect do
              expect(0).not_to be_zero
            end.to fail_check("Expected 0 not to be zero")
          end

          it "matches if the value is positive" do
            expect do
              expect(1).not_to be_zero
            end.to pass_check
          end

          it "matches if the value is negative" do
            expect do
              expect(-1).not_to be_zero
            end.to pass_check
          end
        end
      end
    end
  end
end
