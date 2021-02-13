require "../spec_helper"

Spectator.describe Spectator::Value do
  subject { described_class.new(42, "Test Label") }

  it "stores the value" do
    # NOTE: This cast is a workaround for [issue #55](https://gitlab.com/arctic-fox/spectator/-/issues/55)
    value = subject.as(Spectator::Value(Int32)).value
    expect(value).to eq(42)
  end

  describe "#to_s" do
    subject { super.to_s }

    it "contains the label" do
      is_expected.to contain("Test Label")
    end

    it "contains the value" do
      is_expected.to contain("42")
    end
  end

  describe "#inspect" do
    let(value) { described_class.new([42], "Test Label") }
    subject { value.inspect }

    it "contains the label" do
      is_expected.to contain("Test Label")
    end

    it "contains the value" do
      is_expected.to contain("[42]")
    end
  end
end
