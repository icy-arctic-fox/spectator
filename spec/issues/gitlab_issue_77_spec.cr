require "../spec_helper"

# https://gitlab.com/arctic-fox/spectator/-/issues/77
Spectator.describe "GitLab Issue #77" do
  it "fails" do
    expect_raises do
      raise "Error!"
    end
  end
end
