require "../../spec_helper"

alias ContextHook = Spectator::Core::ContextHook

Spectator.describe ContextHook do
  it "stores the attributes" do
    location = Spectator::Core::LocationRange.new("foo.cr", 42)
    hook = ContextHook.new(:before, location) { }
    expect(hook).to have_attributes(
      position: ContextHook::Position::Before,
      location: location,
      exception: nil,
    )
  end

  describe "#call" do
    it "calls the block" do
      called = false
      hook = ContextHook.new(:before) { called = true }
      expect { hook.call }.to change { called }.to(true)
    end
  end
end
