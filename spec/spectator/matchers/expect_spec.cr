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

    it "sets the example description" do
      example = Spectator::Core::Example.new do |e|
        is_expected.to eq(42)
      end
      Spectator.with_sandbox do |sandbox|
        sandbox.with_example(example, &.run)
      end
      expect(example.description).to eq("is expected to equal 42")
    end

    it "sets the example description when negated" do
      example = Spectator::Core::Example.new do |e|
        is_expected.not_to eq(42)
      end
      Spectator.with_sandbox do |sandbox|
        sandbox.with_example(example, &.run)
      end
      expect(example.description).to eq("is expected not to equal 42")
    end
  end
end
