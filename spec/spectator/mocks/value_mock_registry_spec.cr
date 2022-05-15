require "../../spec_helper"

Spectator.describe Spectator::ValueMockRegistry do
  subject(registry) { Spectator::ValueMockRegistry(Int32).new }
  let(obj) { 42 }
  let(stub) { Spectator::ValueStub.new(:test, 5) }
  let(stubs) { [stub] of Spectator::Stub }
  let(no_stubs) { [] of Spectator::Stub }

  it "initially has no stubs" do
    expect(registry[obj]).to be_empty
  end

  it "stores stubs for an object" do
    expect { registry[obj] << stub }.to change { registry[obj] }.from(no_stubs).to(stubs)
  end

  it "isolates stubs between different objects" do
    obj1 = 1
    obj2 = 2
    registry[obj2] << Spectator::ValueStub.new(:obj2, 42)
    expect { registry[obj1] << stub }.to_not change { registry[obj2] }
  end

  describe "#fetch" do
    it "retrieves existing stubs" do
      registry[obj] << stub
      expect(registry.fetch(obj) { no_stubs }).to eq(stubs)
    end

    it "stores stubs on the first retrieval" do
      expect(registry.fetch(obj) { stubs }).to eq(stubs)
    end

    it "isolates stubs between different objects" do
      obj1 = 1
      obj2 = 2
      registry[obj2] << Spectator::ValueStub.new(:obj2, 42)
      expect { registry.fetch(obj1) { no_stubs } }.to_not change { registry[obj2] }
    end
  end

  describe "#delete" do
    it "clears stubs for an object" do
      registry[obj] << stub
      expect { registry.delete(obj) }.to change { registry[obj] }.from(stubs).to(no_stubs)
    end

    it "doesn't clear initial stubs provided with #fetch" do
      registry[obj] << Spectator::ValueStub.new(:stub2, 42)
      expect { registry.delete(obj) }.to change { registry.fetch(obj) { stubs } }.to(stubs)
    end

    it "isolates stubs between different objects" do
      obj1 = 1
      obj2 = 2
      registry[obj2] << Spectator::ValueStub.new(:obj2, 42)
      expect { registry.delete(obj1) }.to_not change { registry[obj2] }
    end
  end
end
