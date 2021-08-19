require "../spec_helper"

Spectator.describe Spectator::Block do
  describe "#value" do
    it "calls the block" do
      called = false
      block = described_class.new { called = true }
      expect { block.value }.to change { called }.to(true)
    end

    it "can be called multiple times (doesn't cache the value)" do
      count = 0
      block = described_class.new { count += 1 }
      block.value # Call once, count should be 1.
      expect { block.value }.to change { count }.from(1).to(2)
    end
  end

  describe "#to_s" do
    let(block) do
      described_class.new("Test Label") { 42 }
    end

    subject { block.to_s }

    it "contains the label" do
      is_expected.to contain("Test Label")
    end

    it "contains the value" do
      is_expected.to contain("42")
    end
  end
end
