require "../../spec_helper"

alias Sandbox = Spectator::Core::Sandbox

Spectator.describe Sandbox do
  describe "#with_sandbox" do
    it "yields the sandbox" do
      Spectator.with_sandbox do |sandbox|
        expect(sandbox).to be_a(Sandbox)
      end
    end

    it "returns the result of the block" do
      result = Spectator.with_sandbox { "foo" }
      expect(result).to eq("foo")
    end

    it "restores the previous sandbox" do
      previous_sandbox = Spectator.sandbox
      Spectator.with_sandbox do
        expect(Spectator.sandbox).not_to be(previous_sandbox)
      end
      expect(Spectator.sandbox).to be(previous_sandbox)
    end

    it "restores the previous sandbox when an exception is raised" do
      previous_sandbox = Spectator.sandbox
      expect do
        Spectator.with_sandbox { raise "Test error" }
      end.to raise_error("Test error")
      expect(Spectator.sandbox).to be(previous_sandbox)
    end
  end
end
