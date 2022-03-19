require "../spec_helper"

Spectator.describe "eq matcher" do
  it "is true for equal values" do
    expect(42).to eq(42)
  end

  it "is false for unequal values" do
    expect(42).to_not eq(24)
  end

  it "is true for identical references" do
    string = "foobar"
    expect(string).to eq(string)
  end

  it "is false for different references" do
    string1 = "foo"
    string2 = "bar"
    expect(string1).to_not eq(string2)
  end

  double(:fake) do
    stub def ==(other)
      true
    end
  end

  xit "uses the == operator", pending: "Mock redesign" do
    dbl = double(:fake)
    expect(42).to eq(dbl)
    expect(dbl).to have_received(:==).with(42).once
  end
end
