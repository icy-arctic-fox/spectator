require "../spec_helper"

Spectator.describe "GitLab Issue #76" do
  let(:value) { nil.as(Int32?) }
  specify { expect(value).to be_nil }
end
