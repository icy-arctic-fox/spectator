require "../spec_helper"

Spectator.describe Spectator, :smoke do
  it "supports custom expectation messages" do
    expect do
      expect(false).to be_true, "paradox!"
    end.to raise_error(Spectator::ExampleFailed, "paradox!")
  end

  it "supports custom expectation messages with a proc" do
    count = 0
    expect do
      expect(false).to be_true, ->{ count += 1; "Failed #{count} times" }
    end.to raise_error(Spectator::ExampleFailed, "Failed 1 times")
  end

  context "not_to" do
    it "supports custom expectation messages" do
      expect do
        expect(true).not_to be_true, "paradox!"
      end.to raise_error(Spectator::ExampleFailed, "paradox!")
    end

    it "supports custom expectation messages with a proc" do
      count = 0
      expect do
        expect(true).not_to be_true, ->{ count += 1; "Failed #{count} times" }
      end.to raise_error(Spectator::ExampleFailed, "Failed 1 times")
    end
  end
end
