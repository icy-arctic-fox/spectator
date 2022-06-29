require "../../spec_helper"

Spectator.describe Spectator::ValueMockRegistry do
  subject(registry) { Spectator::ValueMockRegistry(Int32).new }
  let(obj) { 42 }
  let(stub) { Spectator::ValueStub.new(:test, 5) }
  let(stubs) { [stub] of Spectator::Stub }
  let(no_stubs) { [] of Spectator::Stub }
  let(call) { Spectator::MethodCall.capture(:method2, 5) }
  let(calls) { [call] }
  let(no_calls) { [] of Spectator::MethodCall }

  it "initially has no stubs" do
    expect(registry[obj].stubs).to be_empty
  end

  it "initially has no calls" do
    expect(registry[obj].calls).to be_empty
  end

  it "stores stubs for an object" do
    expect { registry[obj].stubs << stub }.to change { registry[obj].stubs }.from(no_stubs).to(stubs)
  end

  it "stores calls for an object" do
    expect { registry[obj].calls << call }.to change { registry[obj].calls }.from(no_calls).to(calls)
  end

  it "isolates stubs between different objects" do
    obj1 = 1
    obj2 = 2
    registry[obj2].stubs << Spectator::ValueStub.new(:obj2, 42)
    expect { registry[obj1].stubs << stub }.to_not change { registry[obj2].stubs }
  end

  it "isolates calls between different objects" do
    obj1 = 1
    obj2 = 2
    registry[obj2].calls << Spectator::MethodCall.capture(:method1, 42)
    expect { registry[obj1].calls << call }.to_not change { registry[obj2].calls }
  end

  describe "#fetch" do
    it "retrieves existing stubs" do
      registry[obj].stubs << stub
      expect(registry.fetch(obj) { no_stubs }.stubs).to eq(stubs)
    end

    it "stores stubs on the first retrieval" do
      expect(registry.fetch(obj) { stubs }.stubs).to eq(stubs)
    end

    it "isolates stubs between different objects" do
      obj1 = 1
      obj2 = 2
      registry[obj2].stubs << Spectator::ValueStub.new(:obj2, 42)
      expect { registry.fetch(obj1) { no_stubs }.stubs }.to_not change { registry[obj2].stubs }
    end

    it "isolates calls between different objects" do
      obj1 = 1
      obj2 = 2
      registry[obj2].calls << Spectator::MethodCall.capture(:method1, 42)
      expect { registry.fetch(obj1) { no_stubs }.calls }.to_not change { registry[obj2].calls }
    end
  end

  describe "#delete" do
    it "clears stubs for an object" do
      registry[obj].stubs << stub
      expect { registry.delete(obj) }.to change { registry[obj].stubs }.from(stubs).to(no_stubs)
    end

    it "doesn't clear initial stubs provided with #fetch" do
      registry[obj].stubs << Spectator::ValueStub.new(:stub2, 42)
      expect { registry.delete(obj) }.to change { registry.fetch(obj) { stubs }.stubs }.to(stubs)
    end

    it "isolates stubs between different objects" do
      obj1 = 1
      obj2 = 2
      registry[obj2].stubs << Spectator::ValueStub.new(:obj2, 42)
      expect { registry.delete(obj1) }.to_not change { registry[obj2].stubs }
    end

    it "isolates calls between different objects" do
      obj1 = 1
      obj2 = 2
      registry[obj2].calls << Spectator::MethodCall.capture(:method1, 42)
      expect { registry.delete(obj1) }.to_not change { registry[obj2].calls }
    end
  end
end
