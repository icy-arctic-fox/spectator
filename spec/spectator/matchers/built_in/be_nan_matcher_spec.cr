require "../../../spec_helper"

struct NaNObject
  getter? nan : Bool

  def initialize(@nan : Bool = true)
  end
end

alias BeNaNMatcher = Spectator::Matchers::BuiltIn::BeNaNMatcher

Spectator.describe BeNaNMatcher do
  describe "#matches?" do
    it "returns true if the object is NaN" do
      matcher = BeNaNMatcher.new
      expect(matcher.matches?(NaNObject.new)).to be_true
    end

    it "returns false if the object is not NaN" do
      matcher = BeNaNMatcher.new
      expect(matcher.matches?(NaNObject.new(false))).to be_false
    end

    context "with a Float" do
      it "returns true if the value is NaN" do
        matcher = BeNaNMatcher.new
        expect(matcher.matches?(Float64::NAN)).to be_true
      end

      it "returns false if the value is not NaN" do
        matcher = BeNaNMatcher.new
        expect(matcher.matches?(1.0)).to be_false
      end

      it "returns false if the value is zero" do
        matcher = BeNaNMatcher.new
        expect(matcher.matches?(0.0)).to be_false
      end

      it "returns false if the value is positive infinity" do
        matcher = BeNaNMatcher.new
        expect(matcher.matches?(Float64::INFINITY)).to be_false
      end

      it "returns false if the value is negative infinity" do
        matcher = BeNaNMatcher.new
        expect(matcher.matches?(-Float64::INFINITY)).to be_false
      end
    end

    context "with an Int" do
      it "returns false" do
        matcher = BeNaNMatcher.new
        expect(matcher.matches?(1)).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeNaNMatcher.new
      expect(matcher.failure_message(1.0)).to eq("Expected 1.0 to be NaN")
    end
  end

  describe "#negated_failure_message" do
    it "returns the negated failure message" do
      matcher = BeNaNMatcher.new
      expect(matcher.negated_failure_message(Float64::NAN)).to eq("Expected NaN not to be NaN")
    end
  end

  describe "DSL" do
    describe "`be_nan`" do
      context "with `.to`" do
        it "matches if the object is NaN" do
          expect do
            expect(NaNObject.new).to be_nan
          end.to pass_check
        end

        it "does not match if the object is not NaN" do
          object = NaNObject.new(false)
          expect do
            expect(object).to be_nan
          end.to fail_check("Expected #{object.pretty_inspect} to be NaN")
        end

        context "with a Float" do
          it "matches if the value is NaN" do
            expect do
              expect(Float64::NAN).to be_nan
            end.to pass_check
          end

          it "does not match if the value is not NaN" do
            expect do
              expect(1.0).to be_nan
            end.to fail_check("Expected 1.0 to be NaN")
          end

          it "does not match if the value is zero" do
            expect do
              expect(0.0).to be_nan
            end.to fail_check("Expected 0.0 to be NaN")
          end

          it "does not match if the value is positive infinity" do
            expect do
              expect(Float64::INFINITY).to be_nan
            end.to fail_check("Expected Infinity to be NaN")
          end

          it "does not match if the value is negative infinity" do
            expect do
              expect(-Float64::INFINITY).to be_nan
            end.to fail_check("Expected -Infinity to be NaN")
          end
        end

        context "with an Int" do
          it "does not match" do
            expect do
              expect(1).to be_nan
            end.to fail_check("Expected 1 to be NaN")
          end
        end
      end

      context "with `.not_to`" do
        it "does not match if the object is NaN" do
          object = NaNObject.new
          expect do
            expect(object).not_to be_nan
          end.to fail_check("Expected #{object.pretty_inspect} not to be NaN")
        end

        it "matches if the object is not NaN" do
          expect do
            expect(NaNObject.new(false)).not_to be_nan
          end.to pass_check
        end

        context "with a Float" do
          it "does not match if the value is NaN" do
            expect do
              expect(Float64::NAN).not_to be_nan
            end.to fail_check("Expected NaN not to be NaN")
          end

          it "matches if the value is not NaN" do
            expect do
              expect(1.0).not_to be_nan
            end.to pass_check
          end

          it "matches if the value is zero" do
            expect do
              expect(0.0).not_to be_nan
            end.to pass_check
          end

          it "matches if the value is positive infinity" do
            expect do
              expect(Float64::INFINITY).not_to be_nan
            end.to pass_check
          end

          it "matches if the value is negative infinity" do
            expect do
              expect(-Float64::INFINITY).not_to be_nan
            end.to pass_check
          end
        end

        context "with an Int" do
          it "matches" do
            expect do
              expect(1).not_to be_nan
            end.to pass_check
          end
        end
      end
    end
  end
end
