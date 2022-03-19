require "../spec_helper"

Spectator.describe "GitHub Issue #30" do
  # let(dbl) { double(:foo) }

  xit "supports block-less symbol doubles", pending: "Mock redesign" do
    expect(dbl).to_not be_nil
  end
end
