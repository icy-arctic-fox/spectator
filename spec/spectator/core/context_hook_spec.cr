require "../../spec_helper"

alias ContextHook = Spectator::Core::ContextHook

Spectator.describe ContextHook do
  describe "#call" do
    it "calls the block" do
      called = false
      hook = ContextHook.new(:before) { called = true }
      expect { hook.call }.to change { called }.from(false).to(true)
    end
  end
end
