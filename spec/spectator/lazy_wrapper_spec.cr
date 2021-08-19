require "../spec_helper"

Spectator.describe Spectator::LazyWrapper do
  it "returns the value of the block" do
    expect { subject.get { 42 } }.to eq(42)
  end

  it "caches the value" do
    wrapper = described_class.new
    count = 0
    expect { wrapper.get { count += 1 } }.to change { count }.from(0).to(1)
    expect { wrapper.get { count += 1 } }.to_not change { count }
  end

  # This type of nesting is used when `super` is called in a subject block.
  # ```
  # subject { super.to_s }
  # ```
  it "works with nested wrappers" do
    outer = described_class.new
    inner = described_class.new
    value = outer.get do
      inner.get { 42 }.to_s
    end
    expect(value).to eq("42")
    expect(value).to be_a(String)
  end
end
