require "../../spec_helper"

Spectator.describe Spectator::Core::LocationRange do
  describe "#includes?" do
    it "returns true if the location is in the range" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      location = Spectator::Core::Location.new("foo", 15)
      expect(range.includes?(location)).to be_true
    end

    it "returns false if the location is not in the range" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      location = Spectator::Core::Location.new("bar", 30)
      expect(range.includes?(location)).to be_false
    end

    it "returns true if the files are the same and the location line is omitted" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      location = Spectator::Core::Location.new("foo")
      expect(range.includes?(location)).to be_true
    end

    it "returns false if the files are different" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      location = Spectator::Core::Location.new("bar", 15)
      expect(range.includes?(location)).to be_false
    end
  end

  describe "#===" do
    it "returns true if the location is in the range" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      location = Spectator::Core::Location.new("foo", 15)
      expect(range === location).to be_true
    end

    it "returns false if the location is not in the range" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      location = Spectator::Core::Location.new("bar", 30)
      expect(range === location).to be_false
    end

    it "returns true if the files are the same and the location line is omitted" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      location = Spectator::Core::Location.new("foo")
      expect(range === location).to be_true
    end

    it "returns false if the files are different" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      location = Spectator::Core::Location.new("bar", 15)
      expect(range === location).to be_false
    end
  end

  describe "#to_s" do
    it "returns a string representation" do
      range = Spectator::Core::LocationRange.new("foo", 10, 20)
      expect(range.to_s).to eq("foo:10-20")
    end

    it "returns a string representation with no end line" do
      range = Spectator::Core::LocationRange.new("foo", 10)
      expect(range.to_s).to eq("foo:10")
    end
  end
end
