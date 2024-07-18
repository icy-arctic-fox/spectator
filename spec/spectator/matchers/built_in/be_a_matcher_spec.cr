require "../../../spec_helper"

# Types used to test sub-classes.
class Base
end

class Child < Base
end

Spectator.describe Spectator::Matchers::BuiltIn::BeAMatcher do
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
end
