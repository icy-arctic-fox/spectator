require "../spec_helper"

Spectator.describe "GitLab Issue #86" do
  it "have_value with NamedTuple matches" do
    expect({foo: "bar"}).to have_value("bar")
  end
end
