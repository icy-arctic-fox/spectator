require "../spec_helper"

Spectator.describe Spectator::Lazy do
  it "returns the value of the block" do
    lazy = Spectator::Lazy(Int32).new
    expect { lazy.get { 42 } }.to eq(42)
  end

  it "caches the value" do
    lazy = Spectator::Lazy(Int32).new
    count = 0
    expect { lazy.get { count += 1 } }.to change { count }.from(0).to(1)
    expect { lazy.get { count += 1 } }.to_not change { count }
  end
end
