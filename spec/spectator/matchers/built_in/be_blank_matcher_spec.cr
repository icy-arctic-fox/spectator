require "../../../spec_helper"

private struct BlankObject
  getter? blank : Bool

  def initialize(@blank : Bool = true)
  end
end

alias BeBlankMatcher = Spectator::Matchers::BuiltIn::BeBlankMatcher

Spectator.describe BeBlankMatcher do
  describe "#matches?" do
    it "returns true if the value is blank" do
      matcher = BeBlankMatcher.new
      object = BlankObject.new
      expect(matcher.matches?(object)).to be_true
    end

    it "returns false if the value is not blank" do
      matcher = BeBlankMatcher.new
      object = BlankObject.new(false)
      expect(matcher.matches?(object)).to be_false
    end

    context "with a string" do
      it "returns true if the value is blank" do
        matcher = BeBlankMatcher.new
        expect(matcher.matches?("")).to be_true
      end

      it "returns false if the value is not blank" do
        matcher = BeBlankMatcher.new
        expect(matcher.matches?("foo")).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeBlankMatcher.new
      expect(matcher.failure_message("foo")).to eq("Expected \"foo\" to be blank")
    end
  end

  describe "#negated_failure_message" do
    it "returns the negative failure message" do
      matcher = BeBlankMatcher.new
      expect(matcher.negated_failure_message("foo")).to eq("Expected string not to be blank")
    end
  end

  describe "#to_s" do
    it "returns the description" do
      matcher = BeBlankMatcher.new
      expect(matcher.to_s).to eq("be blank")
    end
  end

  context "DSL" do
    describe "`be_blank`" do
      context "with `.to`" do
        it "matches if the value is blank" do
          object = BlankObject.new
          expect do
            expect(object).to be_blank
          end.to pass_check
        end

        it "does not match if the value is not blank" do
          object = BlankObject.new(false)
          expect do
            expect(object).to be_blank
          end.to fail_check("Expected #{object.pretty_inspect} to be blank")
        end

        context "with a string" do
          it "matches if the value is blank" do
            expect do
              expect("").to be_blank
            end.to pass_check
          end

          it "does not match if the value is not blank" do
            expect do
              expect("foo").to be_blank
            end.to fail_check("Expected \"foo\" to be blank")
          end
        end
      end

      context "with `.not_to`" do
        it "does not match if the value is blank" do
          object = BlankObject.new
          expect do
            expect(object).not_to be_blank
          end.to fail_check("Expected #{object.pretty_inspect} not to be blank")
        end

        it "matches if the value is not blank" do
          object = BlankObject.new(false)
          expect do
            expect(object).not_to be_blank
          end.to pass_check
        end

        context "with a string" do
          it "does not match if the value is blank" do
            expect do
              expect("").not_to be_blank
            end.to fail_check("Expected string not to be blank")
          end

          it "matches if the value is not blank" do
            expect do
              expect("foo").not_to be_blank
            end.to pass_check
          end
        end
      end
    end
  end
end
