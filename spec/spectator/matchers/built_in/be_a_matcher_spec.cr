require "../../../spec_helper"

# Types used to test sub-classes.
class Base
end

class Child < Base
end

alias BeAMatcher = Spectator::Matchers::BuiltIn::BeAMatcher

Spectator.describe BeAMatcher do
  describe "#matches?" do
    it "returns true if the value is an instance of the type" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.matches?(42)).to be_true
    end

    it "returns false if the value is not an instance of the type" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.matches?("foo")).to be_false
    end

    it "returns false if the value is nil" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.matches?(nil)).to be_false
    end

    it "returns true if the value is a subclass of the type" do
      matcher = BeAMatcher(Base).new
      expect(matcher.matches?(Child.new)).to be_true
    end

    it "returns false if the value is a parent of the type" do
      matcher = BeAMatcher(Child).new
      expect(matcher.matches?(Base.new)).to be_false
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.failure_message("foo")).to eq("Expected \"foo\" to be a Int32")
    end
  end

  describe "#negative_failure_message" do
    it "returns the negative failure message" do
      matcher = BeAMatcher(String).new
      expect(matcher.negative_failure_message("foo")).to eq("Expected \"foo\" not to be a String")
    end
  end

  context "DSL" do
    describe "be_a" do
      it "matches if the value is an instance of the type" do
        expect do
          expect(42).to be_a(Int32)
        end.to be_successful
      end

      it "does not match if the value is not an instance of the type" do
        expect do
          expect("foo").to be_a(Int32)
        end.not_to be_successful
      end

      it "does not match if the value is nil" do
        expect do
          expect(nil).to be_a(Int32)
        end.not_to be_successful
      end

      it "matches if the value is a subclass of the type" do
        expect do
          expect(Child.new).to be_a(Base)
        end.to be_successful
      end

      it "does not match if the value is a parent of the type" do
        expect do
          expect(Base.new).to be_a(Child)
        end.not_to be_successful
      end
    end

    describe "be_an" do
      it "matches if the value is an instance of the type" do
        expect do
          expect(42).to be_an(Int32)
        end.to be_successful
      end

      it "does not match if the value is not an instance of the type" do
        expect do
          expect("foo").to be_an(Int32)
        end.not_to be_successful
      end

      it "does not match if the value is nil" do
        expect do
          expect(nil).to be_an(Int32)
        end.not_to be_successful
      end

      it "matches if the value is a subclass of the type" do
        expect do
          expect(Child.new).to be_an(Base)
        end.to be_successful
      end

      it "does not match if the value is a parent of the type" do
        expect do
          expect(Base.new).to be_an(Child)
        end.not_to be_successful
      end
    end
  end
end
