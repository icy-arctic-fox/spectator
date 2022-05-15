require "../../spec_helper"

Spectator.describe Spectator::ReferenceMockRegistry do
  subject(registry) { described_class.new }
  let(obj) { "foobar" }
  let(stub) { Spectator::ValueStub.new(:test, 42) }
  let(no_stubs) { [] of Spectator::Stub }

  it "initially has no stubs" do
    expect(registry[obj]).to be_empty
  end

  it "stores stubs for an object" do
    expect { registry[obj] << stub }.to change { registry[obj] }.from(no_stubs).to([stub])
  end

  it "isolates stubs between different objects" do
    obj1 = "foo"
    obj2 = "bar"
    registry[obj2] << Spectator::ValueStub.new(:obj2, 42)
    expect { registry[obj1] << stub }.to_not change { registry[obj2] }
  end

  describe "#fetch" do
    it "retrieves existing stubs" do
      registry[obj] << stub
      expect(registry.fetch(obj) { no_stubs }).to eq([stub])
    end

    it "stores stubs on the first retrieval" do
      expect(registry.fetch(obj) { [stub] of Spectator::Stub }).to eq([stub])
    end

    it "isolates stubs between different objects" do
      obj1 = "foo"
      obj2 = "bar"
      registry[obj2] << Spectator::ValueStub.new(:obj2, 42)
      expect { registry.fetch(obj2) { no_stubs } }.to_not change { registry[obj2] }
    end
  end
end
