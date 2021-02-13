require "../spec_helper"

Spectator.describe Spectator::Lazy do
  subject { Spectator::Lazy(Int32).new }

  it "returns the value of the block" do
    expect { subject.get { 42 } }.to eq(42)
  end

  it "caches the value" do
    count = 0
    expect { subject.get { count += 1 } }.to change { count }.from(0).to(1)
    expect { subject.get { count += 1 } }.to_not change { count }
  end
end
