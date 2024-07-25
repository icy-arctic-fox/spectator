require "../../../spec_helper"

private struct FiniteObject
  getter? finite : Bool

  def initialize(@finite : Bool = true)
  end
end

alias BeFiniteMatcher = Spectator::Matchers::BuiltIn::BeFiniteMatcher

Spectator.describe BeFiniteMatcher do
  describe "#matches?" do
    it "returns true if the object is finite" do
      matcher = BeFiniteMatcher.new
      expect(matcher.matches?(FiniteObject.new)).to be_true
    end

    it "returns false if the object is infinite" do
      matcher = BeFiniteMatcher.new
      expect(matcher.matches?(FiniteObject.new(false))).to be_false
    end

    context "with a Float" do
      it "returns true if the value is finite" do
        matcher = BeFiniteMatcher.new
        expect(matcher.matches?(1.0)).to be_true
      end

      it "returns false if the value is positive infinity" do
        matcher = BeFiniteMatcher.new
        expect(matcher.matches?(Float64::INFINITY)).to be_false
      end

      it "returns false if the value is negative infinity" do
        matcher = BeFiniteMatcher.new
        expect(matcher.matches?(-Float64::INFINITY)).to be_false
      end
    end

    context "with an Int" do
      it "returns true" do
        matcher = BeFiniteMatcher.new
        expect(matcher.matches?(1)).to be_true
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeFiniteMatcher.new
      object = FiniteObject.new(false)
      expect(matcher.failure_message(object)).to eq("Expected #{object.pretty_inspect} to be finite")
    end

    context "with a Float" do
      it "returns the failure message" do
        matcher = BeFiniteMatcher.new
        expect(matcher.failure_message(Float64::INFINITY)).to eq("Expected Infinity to be finite")
      end
    end
  end

  describe "#negated_failure_message" do
    it "returns the negative failure message" do
      matcher = BeFiniteMatcher.new
      object = FiniteObject.new
      expect(matcher.negated_failure_message(object)).to eq("Expected #{object.pretty_inspect} to be infinite")
    end

    context "with a Float" do
      it "returns the negative failure message" do
        matcher = BeFiniteMatcher.new
        expect(matcher.negated_failure_message(1.0)).to eq("Expected 1.0 to be infinite")
      end
    end

    context "with an Int" do
      it "returns the negative failure message" do
        matcher = BeFiniteMatcher.new
        expect(matcher.negated_failure_message(1)).to eq("Expected 1 to be infinite")
      end
    end
  end

  context "DSL" do
    describe "#be_finite" do
      context "with .to" do
        it "matches a finite value" do
          object = FiniteObject.new
          expect do
            expect(object).to be_finite
          end.to pass_check
        end

        it "does not match an infinite value" do
          object = FiniteObject.new(false)
          expect do
            expect(object).to be_finite
          end.to fail_check("Expected #{object.pretty_inspect} to be finite")
        end

        context "with a Float" do
          it "matches a finite value" do
            expect do
              expect(1.0).to be_finite
            end.to pass_check
          end

          it "does not match positive infinity" do
            expect do
              expect(Float64::INFINITY).to be_finite
            end.to fail_check("Expected Infinity to be finite")
          end

          it "does not match negative infinity" do
            expect do
              expect(-Float64::INFINITY).to be_finite
            end.to fail_check("Expected -Infinity to be finite")
          end
        end

        context "with an Int" do
          it "matches" do
            expect do
              expect(1).to be_finite
            end.to pass_check
          end
        end
      end

      context "with .not_to" do
        it "does not match finite value" do
          object = FiniteObject.new
          expect do
            expect(object).not_to be_finite
          end.to fail_check("Expected #{object.pretty_inspect} to be infinite")
        end

        it "matches an infinite value" do
          object = FiniteObject.new(false)
          expect do
            expect(object).not_to be_finite
          end.to pass_check
        end

        context "with a Float" do
          it "matches a finite value" do
            expect do
              expect(1.0).not_to be_finite
            end.to fail_check("Expected 1.0 to be infinite")
          end

          it "matches positive infinity" do
            expect do
              expect(Float64::INFINITY).not_to be_finite
            end.to pass_check
          end

          it "matches negative infinity" do
            expect do
              expect(-Float64::INFINITY).not_to be_finite
            end.to pass_check
          end
        end

        context "with an Int" do
          it "does not match" do
            expect do
              expect(1).not_to be_finite
            end.to fail_check("Expected 1 to be infinite")
          end
        end
      end
    end
  end
end
