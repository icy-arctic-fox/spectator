require "../../spec_helper"

Spectator.describe Spectator::Core::Location do
  describe ".parse" do
    it "parses a location" do
      location = Spectator::Core::Location.parse("foo:10")
      location.file.should eq("foo")
      location.line?.should eq(10)
    end

    it "parses a location with no line number" do
      location = Spectator::Core::Location.parse("foo")
      location.file.should eq("foo")
      location.line?.should be_nil
    end

    it "parses a Windows path with a colon" do
      location = Spectator::Core::Location.parse("C:\\foo:10")
      location.file.should eq("C:\\foo")
      location.line?.should eq(10)
    end

    it "parses a Windows path with no line number" do
      location = Spectator::Core::Location.parse("C:\\foo")
      location.file.should eq("C:\\foo")
      location.line?.should be_nil
    end
  end

  describe "#to_s" do
    it "constructs a string representation" do
      location = Spectator::Core::Location.new("foo", 10)
      location.to_s.should eq("foo:10")
    end

    it "constructs a string representation with no line number" do
      location = Spectator::Core::Location.new("foo")
      location.to_s.should eq("foo")
    end
  end
end
