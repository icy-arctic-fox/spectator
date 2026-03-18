require "../spec_helper"

Spectator.describe "GitLab Issue #85" do
  it "be_within matches symbols" do
    collection = %i[a b c]
    expect(:a).to be_within(collection)
  end
end
