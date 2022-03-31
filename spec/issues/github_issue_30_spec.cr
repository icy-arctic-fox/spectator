require "../spec_helper"

Spectator.describe "GitHub Issue #30" do
  let(dbl) { double(:foo) }

  it "supports block-less symbol doubles" do
    expect(dbl).to_not be_nil
  end
end
