require "../../../spec_helper"

struct PositiveObject
  getter? positive : Bool

  def initialize(@positive : Bool = true)
  end
end

alias BePositiveMatcher = Spectator::Matchers::BuiltIn::BePositiveMatcher

Spectator.describe BePositiveMatcher do
  describe "#matches?" do
    it "returns true if the object is positive" do
      matcher = BePositiveMatcher.new
      expect(matcher.matches?(PositiveObject.new)).to be_true
    end

    it "returns false if the object is not positive" do
      matcher = BePositiveMatcher.new
      expect(matcher.matches?(PositiveObject.new(false))).to be_false
    end

    context "with a Float" do
      it "returns true if the value is positive" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(1.0)).to be_true
      end

      it "returns false if the value is negative" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(-1.0)).to be_false
      end

      it "returns false if the value is zero" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(0.0)).to be_false
      end

      it "returns true if the value is positive infinity" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(Float64::INFINITY)).to be_true
      end

      it "returns false if the value is negative infinity" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(-Float64::INFINITY)).to be_false
      end

      it "returns false if the value is NaN" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(Float64::NAN)).to be_false
      end
    end

    context "with an Int" do
      it "returns true if the value is positive" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(1)).to be_true
      end

      it "returns false if the value is negative" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(-1)).to be_false
      end

      it "returns false if the value is zero" do
        matcher = BePositiveMatcher.new
        expect(matcher.matches?(0)).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BePositiveMatcher.new
      expect(matcher.failure_message(-1.0)).to eq("Expected -1.0 to be positive")
    end
  end

  describe "#negated_failure_message" do
    it "returns the negated failure message" do
      matcher = BePositiveMatcher.new
      expect(matcher.negated_failure_message(1.0)).to eq("Expected 1.0 not to be positive")
    end
  end

  describe "#to_s" do
    it "returns the description" do
      matcher = BePositiveMatcher.new
      expect(matcher.to_s).to eq("be positive")
    end
  end

  describe "DSL" do
    describe "`be_positive`" do
      context "with `.to`" do
        it "matches if the object is positive" do
          expect do
            expect(PositiveObject.new).to be_positive
          end.to pass_check
        end

        it "does not match if the object is not positive" do
          object = PositiveObject.new(false)
          expect do
            expect(object).to be_positive
          end.to fail_check("Expected #{object.pretty_inspect} to be positive")
        end

        context "with a Float" do
          it "matches if the value is positive" do
            expect do
              expect(1.0).to be_positive
            end.to pass_check
          end

          it "does not match if the value is negative" do
            expect do
              expect(-1.0).to be_positive
            end.to fail_check("Expected -1.0 to be positive")
          end

          it "does not match if the value is zero" do
            expect do
              expect(0.0).to be_positive
            end.to fail_check("Expected 0.0 to be positive")
          end

          it "matches if the value is positive infinity" do
            expect do
              expect(Float64::INFINITY).to be_positive
            end.to pass_check
          end

          it "does not match if the value is negative infinity" do
            expect do
              expect(-Float64::INFINITY).to be_positive
            end.to fail_check("Expected -Infinity to be positive")
          end

          it "does not match if the value is NaN" do
            expect do
              expect(Float64::NAN).to be_positive
            end.to fail_check("Expected NaN to be positive")
          end
        end

        context "with an Int" do
          it "matches if the value is positive" do
            expect do
              expect(1).to be_positive
            end.to pass_check
          end

          it "does not match if the value is negative" do
            expect do
              expect(-1).to be_positive
            end.to fail_check("Expected -1 to be positive")
          end

          it "does not match if the value is zero" do
            expect do
              expect(0).to be_positive
            end.to fail_check("Expected 0 to be positive")
          end
        end
      end

      context "with `.not_to`" do
        it "matches if the object is positive" do
          object = PositiveObject.new
          expect do
            expect(object).not_to be_positive
          end.to fail_check("Expected #{object.pretty_inspect} not to be positive")
        end

        it "does not match if the object is not positive" do
          expect do
            expect(PositiveObject.new(false)).not_to be_positive
          end.to pass_check
        end

        context "with a Float" do
          it "does not match if the value is positive" do
            expect do
              expect(1.0).not_to be_positive
            end.to fail_check("Expected 1.0 not to be positive")
          end

          it "matches if the value is negative" do
            expect do
              expect(-1.0).not_to be_positive
            end.to pass_check
          end

          it "matches if the value is zero" do
            expect do
              expect(0.0).not_to be_positive
            end.to pass_check
          end

          it "does not match if the value is positive infinity" do
            expect do
              expect(Float64::INFINITY).not_to be_positive
            end.to fail_check("Expected Infinity not to be positive")
          end

          it "matches if the value is negative infinity" do
            expect do
              expect(-Float64::INFINITY).not_to be_positive
            end.to pass_check
          end

          it "matches if the value is NaN" do
            expect do
              expect(Float64::NAN).not_to be_positive
            end.to pass_check
          end
        end

        context "with an Int" do
          it "does not match if the value is positive" do
            expect do
              expect(1).not_to be_positive
            end.to fail_check("Expected 1 not to be positive")
          end

          it "matches if the value is negative" do
            expect do
              expect(-1).not_to be_positive
            end.to pass_check
          end

          it "matches if the value is zero" do
            expect do
              expect(0).not_to be_positive
            end.to pass_check
          end
        end
      end
    end
  end
end
