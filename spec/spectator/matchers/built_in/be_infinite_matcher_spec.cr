require "../../../spec_helper"

private struct InfiniteObject
  getter? infinite : Bool

  def initialize(@infinite : Bool = true)
  end
end

alias BeInfiniteMatcher = Spectator::Matchers::BuiltIn::BeInfiniteMatcher

Spectator.describe BeInfiniteMatcher do
  describe "#matches?" do
    it "returns true if the object is infinite" do
      matcher = BeInfiniteMatcher.new
      expect(matcher.matches?(InfiniteObject.new)).to be_true
    end

    it "returns false if the object is finite" do
      matcher = BeInfiniteMatcher.new
      expect(matcher.matches?(InfiniteObject.new(false))).to be_false
    end

    context "with a Float" do
      it "returns true if the value is positive infinity" do
        matcher = BeInfiniteMatcher.new
        expect(matcher.matches?(Float64::INFINITY)).to be_true
      end

      it "returns true if the value is negative infinity" do
        matcher = BeInfiniteMatcher.new
        expect(matcher.matches?(-Float64::INFINITY)).to be_true
      end

      it "returns false if the value is finite" do
        matcher = BeInfiniteMatcher.new
        expect(matcher.matches?(1.0)).to be_false
      end

      it "returns false if the value is zero" do
        matcher = BeInfiniteMatcher.new
        expect(matcher.matches?(0)).to be_false
      end

      it "returns false if the value is NaN" do
        matcher = BeInfiniteMatcher.new
        expect(matcher.matches?(Float64::NAN)).to be_false
      end
    end

    context "with an Int" do
      it "returns false" do
        matcher = BeInfiniteMatcher.new
        expect(matcher.matches?(1)).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeInfiniteMatcher.new
      object = InfiniteObject.new(false)
      expect(matcher.failure_message(object)).to eq("Expected #{object.pretty_inspect} to be infinite")
    end

    context "with a Float" do
      it "returns the failure message" do
        matcher = BeInfiniteMatcher.new
        expect(matcher.failure_message(1.0)).to eq("Expected 1.0 to be infinite")
      end
    end
  end

  describe "#negated_failure_message" do
    it "returns the negative failure message" do
      matcher = BeInfiniteMatcher.new
      object = InfiniteObject.new
      expect(matcher.negated_failure_message(object)).to eq("Expected #{object.pretty_inspect} to be finite")
    end

    context "with a Float" do
      it "returns the negative failure message" do
        matcher = BeInfiniteMatcher.new
        expect(matcher.negated_failure_message(Float64::INFINITY)).to eq("Expected Infinity to be finite")
      end
    end
  end

  context "DSL" do
    describe "#be_infinite" do
      context "with .to" do
        it "does not match a finite value" do
          object = InfiniteObject.new
          expect do
            expect(object).to be_infinite
          end.to pass_check
        end

        it "matches an infinite value" do
          object = InfiniteObject.new(false)
          expect do
            expect(object).to be_infinite
          end.to fail_check("Expected #{object.pretty_inspect} to be infinite")
        end

        context "with a Float" do
          it "does not match a finite value" do
            expect do
              expect(1.0).to be_infinite
            end.to fail_check("Expected 1.0 to be infinite")
          end

          it "matches positive infinity" do
            expect do
              expect(Float64::INFINITY).to be_infinite
            end.to pass_check
          end

          it "matches negative infinity" do
            expect do
              expect(-Float64::INFINITY).to be_infinite
            end.to pass_check
          end

          it "matches zero" do
            expect do
              expect(0.0).to be_infinite
            end.to fail_check("Expected 0.0 to be infinite")
          end

          it "does not match NaN" do
            expect do
              expect(Float64::NAN).to be_infinite
            end.to fail_check("Expected NaN to be infinite")
          end
        end

        context "with an Int" do
          it "does not match" do
            expect do
              expect(1).to be_infinite
            end.to fail_check("Expected 1 to be infinite")
          end
        end
      end

      context "with .not_to" do
        it "matches a finite object" do
          object = InfiniteObject.new(false)
          expect do
            expect(object).not_to be_infinite
          end.to pass_check
        end

        it "does not match an infinite object" do
          object = InfiniteObject.new
          expect do
            expect(object).not_to be_infinite
          end.to fail_check("Expected #{object.pretty_inspect} to be finite")
        end

        context "with a Float" do
          it "matches a finite value" do
            expect do
              expect(1.0).not_to be_infinite
            end.to pass_check
          end

          it "does not match positive infinity" do
            expect do
              expect(Float64::INFINITY).not_to be_infinite
            end.to fail_check("Expected Infinity to be finite")
          end

          it "does not match negative infinity" do
            expect do
              expect(-Float64::INFINITY).not_to be_infinite
            end.to fail_check("Expected -Infinity to be finite")
          end

          it "matches zero" do
            expect do
              expect(0.0).not_to be_infinite
            end.to pass_check
          end

          it "matches NaN" do
            expect do
              expect(Float64::NAN).not_to be_infinite
            end.to pass_check
          end
        end

        context "with an Int" do
          it "matches" do
            expect do
              expect(1).not_to be_infinite
            end.to pass_check
          end
        end
      end
    end
  end
end
