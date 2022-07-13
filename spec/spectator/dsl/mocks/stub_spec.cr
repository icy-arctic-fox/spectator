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

  describe "#with" do
    context Spectator::MultiValueStub do
      it "applies the stub with matching arguments" do
        allow(dbl).to receive(:foo).and_return(1, 2, 3).with(Int32, bar: /baz/)
        aggregate_failures do
          expect(dbl.foo(3, bar: "foobarbaz")).to eq(1)
          expect(dbl.foo).to eq(42)
          expect(dbl.foo(5, bar: "barbaz")).to eq(2)
          expect(dbl.foo(7, bar: "foobaz")).to eq(3)
          expect(dbl.foo(11, bar: "baz")).to eq(3)
        end
      end
    end

    context Spectator::NullStub do
      it "applies the stub with matching arguments" do
        allow(dbl).to receive(:foo).with(Int32, bar: /baz/).and_return(1)
        aggregate_failures do
          expect(dbl.foo(3, bar: "foobarbaz")).to eq(1)
          expect(dbl.foo).to eq(42)
        end
      end

      it "changes to a proc stub" do
        called = 0
        allow(dbl).to receive(:foo).with(Int32, bar: /baz/) { called += 1 }
        aggregate_failures do
          expect { dbl.foo(3, bar: "foobarbaz") }.to change { called }.from(0).to(1)
          expect(dbl.foo(5, bar: "baz")).to eq(2)
          expect(dbl.foo).to eq(42)
        end
      end
    end

    context Spectator::ValueStub do
      it "applies the stub with matching arguments" do
        allow(dbl).to receive(:foo).and_return(1).with(Int32, bar: /baz/)
        aggregate_failures do
          expect(dbl.foo(3, bar: "foobarbaz")).to eq(1)
          expect(dbl.foo).to eq(42)
        end
      end
    end
  end

  describe "#no_args" do
    it "defines a stub with a no arguments constraint" do
      allow(dbl).to receive(:foo).with(no_args).and_return(5)
      aggregate_failures do
        expect(dbl.foo).to eq(5)
        expect(dbl.foo(0)).to eq(42)
      end
    end
  end

  describe "#any_args" do
    it "defines a stub with no arguments constraint" do
      allow(dbl).to receive(:foo).with(any_args).and_return(5)
      aggregate_failures do
        expect(dbl.foo).to eq(5)
        expect(dbl.foo(0)).to eq(5)
      end
    end
  end
end
