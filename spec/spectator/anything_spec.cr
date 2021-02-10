require "../spec_helper"

Spectator.describe Spectator::Anything do
  it "equals everything" do
    expect(true).to eq(subject)
    expect(false).to eq(subject)
    expect(nil).to eq(subject)
    expect(42).to eq(subject)
    expect(42.as(Int32 | String)).to eq(subject)
    expect(["foo", "bar"]).to eq(subject)
  end

  it "matches everything" do
    expect(true).to match(subject)
    expect(false).to match(subject)
    expect(nil).to match(subject)
    expect(42).to match(subject)
    expect(42.as(Int32 | String)).to match(subject)
    expect(["foo", "bar"]).to match(subject)
  end

  context "nested in a container" do
    it "equals everything" do
      expect(["foo", "bar"]).to eq(["foo", subject])
      expect({"foo", "bar"}).to eq({"foo", subject})
      expect({foo: "bar"}).to eq({foo: subject})
      expect({"foo" => "bar"}).to eq({"foo" => subject})
    end

    it "matches everything" do
      expect(["foo", "bar"]).to match(["foo", subject])
      expect({"foo", "bar"}).to match({"foo", subject})
      expect({foo: "bar"}).to match({foo: subject})
      expect({"foo" => "bar"}).to match({"foo" => subject})
    end
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
