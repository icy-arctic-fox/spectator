require "../../../spec_helper"

private record SizeableObject, size : Int32

alias HaveSizeMatcher = Spectator::Matchers::BuiltIn::HaveSizeMatcher

Spectator.describe HaveSizeMatcher do
  describe "#matches?" do
    it "returns true if the object has the same size" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.matches?(SizeableObject.new(42))).to be_true
    end

    it "returns false if the object has a different size" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.matches?(SizeableObject.new(24))).to be_false
    end

    it "returns true if the object has, and expected to have, zero elements" do
      matcher = HaveSizeMatcher.new(0)
      expect(matcher.matches?(SizeableObject.new(0))).to be_true
    end

    it "returns false if the object has, and not expected to have, zero elements" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.matches?(SizeableObject.new(0))).to be_false
    end

    it "returns false if the object has, and not expected to have, some elements" do
      matcher = HaveSizeMatcher.new(0)
      expect(matcher.matches?(SizeableObject.new(42))).to be_false
    end

    it "returns false if the object doesn't have a size" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.matches?(nil)).to be_false
    end

    context "with an Array" do # Common use case.
      it "returns true if the array has the same size" do
        matcher = HaveSizeMatcher.new(3)
        expect(matcher.matches?([1, 2, 3])).to be_true
      end

      it "returns false if the array has a different size" do
        matcher = HaveSizeMatcher.new(5)
        expect(matcher.matches?([1, 2, 3])).to be_false
      end

      it "returns true if the array has, and expected to have, zero elements" do
        matcher = HaveSizeMatcher.new(0)
        expect(matcher.matches?([] of Int32)).to be_true
      end

      it "returns false if the array has, and not expected to have, zero elements" do
        matcher = HaveSizeMatcher.new(42)
        expect(matcher.matches?([] of Int32)).to be_false
      end

      it "returns false if the array has, and not expected to have, some elements" do
        matcher = HaveSizeMatcher.new(0)
        expect(matcher.matches?([1, 2, 3])).to be_false
      end
    end
  end

  describe "#does_not_match?" do
    it "returns false if the object has the same size" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.does_not_match?(SizeableObject.new(42))).to be_false
    end

    it "returns true if the object has a different size" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.does_not_match?(SizeableObject.new(24))).to be_true
    end

    it "returns false if the object has, and expected to have, zero elements" do
      matcher = HaveSizeMatcher.new(0)
      expect(matcher.does_not_match?(SizeableObject.new(0))).to be_false
    end

    it "returns true if the object has, and not expected to have, zero elements" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.does_not_match?(SizeableObject.new(0))).to be_true
    end

    it "returns true if the object has, and not expected to have, some elements" do
      matcher = HaveSizeMatcher.new(0)
      expect(matcher.does_not_match?(SizeableObject.new(42))).to be_true
    end

    it "returns true if the object doesn't have a size" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.does_not_match?(nil)).to be_true
    end

    context "with an Array" do # Common use case.
      it "returns false if the array has the same size" do
        matcher = HaveSizeMatcher.new(3)
        expect(matcher.does_not_match?([1, 2, 3])).to be_false
      end

      it "returns true if the array has a different size" do
        matcher = HaveSizeMatcher.new(5)
        expect(matcher.does_not_match?([1, 2, 3])).to be_true
      end

      it "returns false if the array has, and expected to have, zero elements" do
        matcher = HaveSizeMatcher.new(0)
        expect(matcher.does_not_match?([] of Int32)).to be_false
      end

      it "returns true if the array has, and not expected to have, zero elements" do
        matcher = HaveSizeMatcher.new(42)
        expect(matcher.does_not_match?([] of Int32)).to be_true
      end

      it "returns true if the array has, and not expected to have, some elements" do
        matcher = HaveSizeMatcher.new(0)
        expect(matcher.does_not_match?([1, 2, 3])).to be_true
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = HaveSizeMatcher.new(5)
      object = SizeableObject.new(3)
      expect(matcher.failure_message(object)).to eq <<-EOS
      Expected: #{object.pretty_inspect}
       to have: 5 elements
       but has: 3 elements
      EOS
    end

    it "checks for size method" do
      matcher = HaveSizeMatcher.new(5)
      object = true
      expect(matcher.failure_message(object)).to eq <<-EOS
      Expected: true
       to have: 5 elements
      but has no size
      EOS
    end

    context "with an Array" do
      it "returns the failure message" do
        matcher = HaveSizeMatcher.new(5)
        expect(matcher.failure_message([1, 2, 3])).to eq <<-EOS
        Expected: [1, 2, 3]
         to have: 5 elements
         but has: 3 elements
        EOS
      end
    end
  end

  describe "#negated_failure_message" do
    it "returns the failure message" do
      matcher = HaveSizeMatcher.new(3)
      object = SizeableObject.new(3)
      expect(matcher.negated_failure_message(object)).to eq <<-EOS
         Expected: #{object.pretty_inspect}
      not to have: 3 elements
      EOS
    end

    context "with an Array" do
      it "returns the failure message" do
        matcher = HaveSizeMatcher.new(3)
        expect(matcher.negated_failure_message([1, 2, 3])).to eq <<-EOS
           Expected: [1, 2, 3]
        not to have: 3 elements
        EOS
      end
    end
  end

  describe "#to_s" do
    it "returns the description" do
      matcher = HaveSizeMatcher.new(42)
      expect(matcher.to_s).to eq("have 42 elements")
    end
  end

  context "DSL" do
    describe "`have_size`" do
      context "with `.to`" do
        it "matches an equal size" do
          object = SizeableObject.new(42)
          expect do
            expect(object).to have_size(42)
          end.to pass_check
        end

        it "does not match an inequal size" do
          object = SizeableObject.new(42)
          expect do
            expect(object).to have_size(24)
          end.to fail_check <<-EOS
          Expected: #{object.pretty_inspect}
           to have: 24 elements
           but has: 42 elements
          EOS
        end

        it "matches an equal size of 0" do
          object = SizeableObject.new(0)
          expect do
            expect(object).to have_size(0)
          end.to pass_check
        end

        it "does not match an inequal size of non-zero" do
          object = SizeableObject.new(42)
          expect do
            expect(object).to have_size(0)
          end.to fail_check <<-EOS
          Expected: #{object.pretty_inspect}
           to have: 0 elements
           but has: 42 elements
          EOS
        end

        it "does not match an inequal size of 0" do
          object = SizeableObject.new(0)
          expect do
            expect(object).to have_size(42)
          end.to fail_check <<-EOS
          Expected: #{object.pretty_inspect}
           to have: 42 elements
           but has: 0 elements
          EOS
        end

        it "does not match an object without a size" do
          expect do
            expect(nil).to have_size(42)
          end.to fail_check <<-EOS
          Expected: nil
           to have: 42 elements
          but has no size
          EOS
        end

        context "with an Array" do
          it "matches an equal size" do
            expect do
              expect([1, 2, 3]).to have_size(3)
            end.to pass_check
          end

          it "does not match an inequal size" do
            expect do
              expect([1, 2, 3]).to have_size(5)
            end.to fail_check <<-EOS
            Expected: [1, 2, 3]
             to have: 5 elements
             but has: 3 elements
            EOS
          end

          it "matches an equal size of 0" do
            expect do
              expect([] of Int32).to have_size(0)
            end.to pass_check
          end

          it "does not match an inequal size of non-zero" do
            expect do
              expect([1, 2, 3]).to have_size(0)
            end.to fail_check <<-EOS
            Expected: [1, 2, 3]
             to have: 0 elements
             but has: 3 elements
            EOS
          end

          it "does not match an inequal size of 0" do
            expect do
              expect([] of Int32).to have_size(42)
            end.to fail_check <<-EOS
            Expected: []
             to have: 42 elements
             but has: 0 elements
            EOS
          end
        end
      end

      context "with `.not_to`" do
        it "does not match an equal size" do
          object = SizeableObject.new(42)
          expect do
            expect(object).not_to have_size(42)
          end.to fail_check <<-EOS
             Expected: #{object.pretty_inspect}
          not to have: 42 elements
          EOS
        end

        it "matches an inequal size" do
          object = SizeableObject.new(42)
          expect do
            expect(object).not_to have_size(24)
          end.to pass_check
        end

        it "does not match an equal size of 0" do
          object = SizeableObject.new(0)
          expect do
            expect(object).not_to have_size(0)
          end.to fail_check <<-EOS
             Expected: #{object.pretty_inspect}
          not to have: 0 elements
          EOS
        end

        it "matches an inequal size of non-zero" do
          object = SizeableObject.new(42)
          expect do
            expect(object).not_to have_size(0)
          end.to pass_check
        end

        it "matches an inequal size of 0" do
          object = SizeableObject.new(0)
          expect do
            expect(object).not_to have_size(42)
          end.to pass_check
        end

        it "matches an object without a size" do
          expect do
            expect(nil).not_to have_size(42)
          end.to pass_check
        end

        context "with an Array" do
          it "does not match an equal size" do
            expect do
              expect([1, 2, 3]).not_to have_size(3)
            end.to fail_check <<-EOS
               Expected: [1, 2, 3]
            not to have: 3 elements
            EOS
          end

          it "matches an inequal size" do
            expect do
              expect([1, 2, 3]).not_to have_size(5)
            end.to pass_check
          end

          it "does not match an equal size of 0" do
            expect do
              expect([] of Int32).not_to have_size(0)
            end.to fail_check <<-EOS
               Expected: []
            not to have: 0 elements
            EOS
          end

          it "matches an inequal size from non-zero" do
            expect do
              expect([1, 2, 3]).not_to have_size(0)
            end.to pass_check
          end

          it "matches an inequal size from 0" do
            expect do
              expect([] of Int32).not_to have_size(42)
            end.to pass_check
          end
        end
      end
    end
  end
end
