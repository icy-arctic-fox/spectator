require "../spec_helper"

Spectator.describe Spectator::Anything do
  it "matches everything" do
    expect(true).to match(subject)
    expect(false).to match(subject)
    expect(nil).to match(subject)
    expect(42).to match(subject)
    expect(42.as(Int32 | String)).to match(subject)
    expect(["foo", "bar"]).to match(subject)
  end

  describe "#to_s" do
    subject { super.to_s }

    it { is_expected.to contain("anything") }
  end

  describe "#inspect" do
    subject { super.inspect }

    it { is_expected.to contain("anything") }
  end
end
