require "../../spec_helper"

Spectator.describe Spectator::Core::Location do
  describe ".parse" do
    it "parses a location" do
      location = Spectator::Core::Location.parse("foo:10")
      expect(location.file).to eq("foo")
      expect(location.line?).to eq(10)
    end

    it "parses a location with no line number" do
      location = Spectator::Core::Location.parse("foo")
      expect(location.file).to eq("foo")
      expect(location.line?).to be_nil
    end

    it "parses a Windows path with a colon" do
      location = Spectator::Core::Location.parse("C:\\foo:10")
      expect(location.file).to eq("C:\\foo")
      expect(location.line?).to eq(10)
    end

    it "parses a Windows path with no line number" do
      location = Spectator::Core::Location.parse("C:\\foo")
      expect(location.file).to eq("C:\\foo")
      expect(location.line?).to be_nil
    end
  end

  describe "#to_s" do
    it "constructs a string representation" do
      location = Spectator::Core::Location.new("foo", 10)
      expect(location.to_s).to eq("foo:10")
    end

    it "constructs a string representation with no line number" do
      location = Spectator::Core::Location.new("foo")
      expect(location.to_s).to eq("foo")
    end
  end
end
