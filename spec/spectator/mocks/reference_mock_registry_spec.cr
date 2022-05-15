require "../../spec_helper"

Spectator.describe Spectator::ReferenceMockRegistry do
  subject(registry) { described_class.new }
  let(stub) { Spectator::ValueStub.new(:test, 42) }

  it "initially has no stubs" do
    obj = "foobar"
    expect(registry[obj]).to be_empty
  end

  it "stores stubs for an object" do
    obj = "foobar"
    expect { registry[obj] << stub }.to change { registry[obj] }.from([] of Spectator::Stub).to([stub])
  end

  it "isolates stubs between different objects" do
    obj1 = "foo"
    obj2 = "bar"
    registry[obj2] << Spectator::ValueStub.new(:obj2, 42)
    expect { registry[obj1] << stub }.to_not change { registry[obj2] }
  end
end
