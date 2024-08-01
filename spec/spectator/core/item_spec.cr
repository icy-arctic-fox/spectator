require "../../spec_helper"

# TODO: Use a mock.
private class TestItem < Spectator::Core::Item
  def run? : Bool
    false
  end
end

Spectator.describe Spectator::Core::Item do
  describe "#description" do
    it "is the string passed to #initialize" do
      item = TestItem.new("foo")
      expect(item.description).to eq("foo")
    end

    it "is nil if the item does not have a description" do
      item = TestItem.new
      expect(item.description).to be_nil
    end

    it "is the result of #inspect when passing a non-string to #initialize" do
      item = TestItem.new(:xyz)
      expect(item.description).to eq(":xyz")
    end
  end

  describe "#location" do
    it "is the value passed to #initialize" do
      location = Spectator::Core::LocationRange.new("foo", 10)
      item = TestItem.new("foo", location)
      expect(item.location).to eq(location)
    end
  end
end
