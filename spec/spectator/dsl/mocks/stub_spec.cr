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

  describe "#receive" do
    it "returns the value from the block" do
      allow(dbl).to receive(:foo) { 5 }
      expect(dbl.foo).to eq(5)
    end

    it "accepts and calls block" do
      count = 0
      allow(dbl).to receive(:foo) { count += 1 }
      expect { dbl.foo }.to change { count }.from(0).to(1)
    end

    it "passes the arguments to the block" do
      captured = nil.as(Spectator::AbstractArguments?)
      allow(dbl).to receive(:foo) { |a| captured = a; 0 }
      dbl.foo(3, 5, 7, bar: "baz")
      args = Spectator::Arguments.capture(3, 5, 7, bar: "baz")
      expect(captured).to eq(args)
    end
  end
end
