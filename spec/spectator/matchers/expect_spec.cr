require "../../spec_helper"

alias Expect = Spectator::Matchers::Expect

Spectator.describe Expect do
end

Spectator.describe Spectator::Matchers::ExpectMethods do
  describe "#is_expected" do
    let subject = 42

    it "uses the subject" do
      is_expected.to eq(42)
    end
  end
end
