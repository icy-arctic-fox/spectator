require "../../../spec_helper"

Spectator.describe "Stub DSL", :smoke do
  double(:foobar, foo: 42, bar: "baz") do
    stub abstract def other : String
    stub abstract def null : Nil
  end

  let(dbl) { double(:foobar) }

  it "overrides default stubs" do
    allow(dbl).to receive(:foo).and_return(123)
    expect(dbl.foo).to eq(123)
  end

  it "overrides abstract stubs" do
    allow(dbl).to receive(:other).and_return("test")
    expect(dbl.other).to eq("test")
  end

  it "returns nil by default" do
    allow(dbl).to receive(:null)
    expect(dbl.null).to be_nil
  end

  it "raises on cast errors" do
    allow(dbl).to receive(:foo).and_return(:xyz)
    expect { dbl.foo }.to raise_error(TypeCastError, /Int32/)
  end
end
