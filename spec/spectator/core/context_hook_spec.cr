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

    it "calls the hook once" do
      count = 0
      hook = ContextHook.new(:before) { count += 1 }
      expect do
        2.times { hook.call }
      end.to change { count }.to(1)
    end

    it "captures exceptions" do
      error = RuntimeError.new("error")
      hook = ContextHook.new(:before) { raise error }
      expect { hook.call }.to raise_error(error)
      expect(hook.exception).to eq(error)
    end

    it "re-raises previous exceptions" do
      error = RuntimeError.new("error")
      called = false
      hook = ContextHook.new(:before) do
        next if called
        called = true
        raise error
      end
      expect { hook.call }.to raise_error(error)
      expect { hook.call }.to raise_error(error) # Same error instance is raised.
    end
  end
end
