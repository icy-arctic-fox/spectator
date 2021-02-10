require "../spec_helper"

Spectator.describe Spectator::Value do
  subject { described_class.new(42, "Test Label") }

  it "stores the value" do
    expect(&.value).to eq(42)
  end

  # TODO: Fix issue with compile-time type of `subject` being a union.
  # describe "#to_s" do
  #   subject { super.to_s }
  #
  #   it "contains the label" do
  #     is_expected.to contain("Test Label")
  #   end
  #
  #   it "contains the value" do
  #     is_expected.to contain("42")
  #   end
  # end
  #
  # describe "#inspect" do
  #   let(value) { described_class.new([42], "Test Label") }
  #   subject { value.inspect }
  #
  #   it "contains the label" do
  #     is_expected.to contain("Test Label")
  #   end
  #
  #   it "contains the value" do
  #     is_expected.to contain("[42]")
  #   end
  # end
end
