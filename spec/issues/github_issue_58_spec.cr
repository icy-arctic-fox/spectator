require "../spec_helper"

Spectator.describe "test" do
  it_fails "should not pass #1" do
    expect([1, 2, 3]).to(match_array([2, 3, 1]).in_order)
  end

  it_fails "should not pass #2" do
    expect([1, 2, 3]).to(contain_exactly(2, 3, 1).in_order)
  end

  it "should pass" do
    expect([1, 2, 3]).to(match_array([1, 2, 3]).in_order)
  end
end
