require "../../../spec_helper"

private struct EmptyObject
  getter? empty = true

  def initialize(@empty : Bool = true)
  end
end

alias BeEmptyMatcher = Spectator::Matchers::BuiltIn::BeEmptyMatcher

Spectator.describe BeEmptyMatcher do
  describe "#matches?" do
    it "returns true if the value is empty" do
      matcher = BeEmptyMatcher.new
      object = EmptyObject.new
      expect(matcher.matches?(object)).to be_true
    end

    it "returns false if the value is not empty" do
      matcher = BeEmptyMatcher.new
      object = EmptyObject.new(false)
      expect(matcher.matches?(object)).to be_false
    end

    context "with an array" do
      it "returns true if the value is empty" do
        matcher = BeEmptyMatcher.new
        expect(matcher.matches?([] of Int32)).to be_true
      end

      it "returns false if the value is not empty" do
        matcher = BeEmptyMatcher.new
        expect(matcher.matches?([1, 2, 3])).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeEmptyMatcher.new
      object = EmptyObject.new(false)
      expect(matcher.failure_message(object)).to match(/^Expected .*?EmptyObject.+? to be empty$/)
    end

    context "with an array" do
      it "returns the failure message" do
        matcher = BeEmptyMatcher.new
        expect(matcher.failure_message([1, 2, 3])).to eq("Expected [1, 2, 3] to be empty")
      end
    end
  end

  describe "#negated_failure_message" do
    it "returns the negative failure message" do
      matcher = BeEmptyMatcher.new
      object = EmptyObject.new
      expect(matcher.negated_failure_message(object)).to match(/^Expected .*?EmptyObject.+? not to be empty$/)
    end

    context "with an array" do
      it "returns the negative failure message" do
        matcher = BeEmptyMatcher.new
        expect(matcher.negated_failure_message([] of Int32)).to eq("Expected [] not to be empty")
      end
    end
  end

  context "DSL" do
    describe "be_empty" do
      context "with .to" do
        it "matches if the value is empty" do
          expect do
            expect(EmptyObject.new).to be_empty
          end.to pass_check
        end

        it "does not match if the value is not empty" do
          expect do
            expect(EmptyObject.new(false)).to be_empty
          end.to fail_check(/^Expected .*?EmptyObject.+? to be empty$/)
        end

        context "with an array" do
          it "matches if the value is empty" do
            expect do
              expect([] of Int32).to be_empty
            end.to pass_check
          end

          it "does not match if the value is not empty" do
            expect do
              expect([1, 2, 3]).to be_empty
            end.to fail_check("Expected [1, 2, 3] to be empty")
          end
        end
      end

      context "with .not_to" do
        it "does not match if the value is empty" do
          expect do
            expect(EmptyObject.new).not_to be_empty
          end.to fail_check(/^Expected .*?EmptyObject.+? not to be empty$/)
        end

        it "matches if the value is not empty" do
          expect do
            expect(EmptyObject.new(false)).not_to be_empty
          end.to pass_check
        end

        context "with an array" do
          it "does not match if the value is empty" do
            expect do
              expect([] of Int32).not_to be_empty
            end.to fail_check("Expected [] not to be empty")
          end

          it "matches if the value is not empty" do
            expect do
              expect([1, 2, 3]).not_to be_empty
            end.to pass_check
          end
        end
      end
    end
  end
end
