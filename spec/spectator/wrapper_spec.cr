require "../spec_helper"

Spectator.describe Spectator::Wrapper do
  it "stores a value" do
    wrapper = described_class.new(42)
    expect(wrapper.get(Int32)).to eq(42)
  end

  it "retrieves a value using the block trick" do
    wrapper = described_class.new(Int32)
    expect(wrapper.get { Int32 }).to eq(Int32)
  end
end
