require "../../spec_helper"

Spectator.describe Spectator::NullDouble do
  Spectator::NullDouble.define(EmptyDouble)
  Spectator::NullDouble.define(FooBarDouble, "dbl-name", foo: 42, bar: "baz")

  # The subject `dbl` must be carefully used in sub-contexts, otherwise it pollutes parent scopes.
  # This changes the type of `dbl` to `Double`, which produces a union of methods and their return types.
  context "plain double" do
    subject(dbl) { FooBarDouble.new }

    it "responds to defined messages" do
      aggregate_failures do
        expect(dbl.foo).to eq(42)
        expect(dbl.bar).to eq("baz")
      end
    end

    it "returns self on undefined messages" do
      expect(dbl.baz).to be(dbl)
    end

    it "has a non-union return type" do
      aggregate_failures do
        expect(dbl.foo).to compile_as(Int32)
        expect(dbl.bar).to compile_as(String)
      end
    end

    context "blocks" do
      it "supports blocks" do
        aggregate_failures do
          expect(dbl.foo { nil }).to eq(42)
          expect(dbl.bar { nil }).to eq("baz")
        end
      end

      it "supports blocks and has non-union return types" do
        aggregate_failures do
          expect(dbl.foo { nil }).to compile_as(Int32)
          expect(dbl.bar { nil }).to compile_as(String)
        end
      end

      it "returns self on undefined messages" do
        expect(dbl.baz { nil }).to be(dbl)
      end
    end
  end

  context "with abstract stubs and return type annotations" do
    Spectator::NullDouble.define(TestDouble2) do
      abstract_stub abstract def foo(value) : String
    end

    let(arguments) { Spectator::Arguments.capture(/foo/) }
    let(stub) { Spectator::ValueStub.new(:foo, "bar", arguments).as(Spectator::Stub) }
    subject(dbl) { TestDouble2.new([stub]) }

    it "enforces the return type" do
      expect(dbl.foo("foobar")).to compile_as(String)
    end

    it "raises on non-matching arguments" do
      expect { dbl.foo("bar") }.to raise_error(TypeCastError, /String/)
    end

    it "raises on non-matching stub" do
      stub = Spectator::ValueStub.new(:foo, 42, arguments).as(Spectator::Stub)
      dbl._spectator_define_stub(stub)
      expect { dbl.foo("foobar") }.to raise_error(TypeCastError, /String/)
    end
  end

  context "with nillable return type annotations" do
    Spectator::NullDouble.define(TestDouble) do
      abstract_stub abstract def foo : String?
      abstract_stub abstract def bar : Nil
    end

    let(foo_stub) { Spectator::ValueStub.new(:foo, nil).as(Spectator::Stub) }
    let(bar_stub) { Spectator::ValueStub.new(:bar, nil).as(Spectator::Stub) }
    subject(dbl) { TestDouble.new([foo_stub, bar_stub]) }

    it "doesn't raise on nil" do
      aggregate_failures do
        expect(dbl.foo).to be_nil
        expect(dbl.bar).to be_nil
      end
    end
  end

  context "with common object methods" do
    subject(dbl) do
      EmptyDouble.new([
        Spectator::ValueStub.new(:"!=", "!="),
        Spectator::ValueStub.new(:"!~", "!~"),
        Spectator::ValueStub.new(:"==", "=="),
        Spectator::ValueStub.new(:"===", "==="),
        Spectator::ValueStub.new(:"=~", "=~"),
        Spectator::ValueStub.new(:class, "class"),
        Spectator::ValueStub.new(:dup, "dup"),
        Spectator::ValueStub.new(:hash, "hash"),
        Spectator::ValueStub.new(:"in?", true),
        Spectator::ValueStub.new(:inspect, "inspect"),
        Spectator::ValueStub.new(:itself, "itself"),
        Spectator::ValueStub.new(:"not_nil!", "not_nil!"),
        Spectator::ValueStub.new(:pretty_inspect, "pretty_inspect"),
        Spectator::ValueStub.new(:tap, "tap"),
        Spectator::ValueStub.new(:to_json, "to_json"),
        Spectator::ValueStub.new(:to_pretty_json, "to_pretty_json"),
        Spectator::ValueStub.new(:to_s, "to_s"),
        Spectator::ValueStub.new(:to_yaml, "to_yaml"),
        Spectator::ValueStub.new(:try, "try"),
        Spectator::ValueStub.new(:object_id, 42_u64),
        Spectator::ValueStub.new(:"same?", true),
      ] of Spectator::Stub)
    end

    it "responds with defined messages" do
      hasher = Crystal::Hasher.new
      aggregate_failures do
        expect(dbl.!=(42)).to eq("!=")
        expect(dbl.!~(42)).to eq("!~")
        expect(dbl.==(42)).to eq("==")
        expect(dbl.===(42)).to eq("===")
        expect(dbl.=~(42)).to eq("=~")
        expect(dbl.class).to eq("class")
        expect(dbl.dup).to eq("dup")
        expect(dbl.hash(hasher)).to eq("hash")
        expect(dbl.hash).to eq("hash")
        expect(dbl.in?([42])).to eq(true)
        expect(dbl.in?(1, 2, 3)).to eq(true)
        expect(dbl.inspect).to eq("inspect")
        expect(dbl.itself).to eq("itself")
        expect(dbl.not_nil!).to eq("not_nil!")
        expect(dbl.pretty_inspect).to eq("pretty_inspect")
        expect(dbl.tap { nil }).to eq("tap")
        expect(dbl.to_json).to eq("to_json")
        expect(dbl.to_pretty_json).to eq("to_pretty_json")
        expect(dbl.to_s).to eq("to_s")
        expect(dbl.to_yaml).to eq("to_yaml")
        expect(dbl.try { nil }).to eq("try")
        expect(dbl.object_id).to eq(42_u64)
        expect(dbl.same?(dbl)).to eq(true)
        expect(dbl.same?(nil)).to eq(true)
      end
    end

    it "has a non-union return type" do
      expect(dbl.inspect).to compile_as(String)
    end
  end

  context "without common object methods" do
    subject(dbl) { EmptyDouble.new }

    it "returns self with undefined messages" do
      hasher = Crystal::Hasher.new
      aggregate_failures do
        # Methods that would cause type cast errors are omitted from this list.
        expect(dbl.!=(42)).to be(dbl)
        expect(dbl.!~(42)).to be(dbl)
        expect(dbl.==(42)).to be(dbl)
        expect(dbl.===(42)).to be(dbl)
        expect(dbl.=~(42)).to be(dbl)
        expect(dbl.class).to be(dbl)
        expect(dbl.dup).to be(dbl)
        expect(dbl.hash(hasher)).to be(dbl)
        expect(dbl.hash).to be(dbl)
        expect(dbl.itself).to be(dbl)
        expect(dbl.not_nil!).to be(dbl)
        expect(dbl.tap { nil }).to be(dbl)
        expect(dbl.try { nil }).to be(dbl)
      end
    end
  end

  context "with arguments constraints" do
    let(arguments) { Spectator::Arguments.capture(/foo/) }

    context "without common object methods" do
      Spectator::NullDouble.define(TestDouble) do
        abstract_stub abstract def foo(value)
        abstract_stub abstract def foo(value, & : -> _)
      end

      let(stub) { Spectator::ValueStub.new(:foo, "bar", arguments).as(Spectator::Stub) }
      subject(dbl) { TestDouble.new([stub]) }

      it "returns the response when constraint satisfied" do
        expect(dbl.foo("foobar")).to eq("bar")
      end

      it "returns self when constraint unsatisfied" do
        expect(dbl.foo("baz")).to be(dbl)
      end

      it "returns self when argument count doesn't match" do
        expect(dbl.foo).to be(dbl)
      end

      it "ignores the block argument if not in the constraint" do
        expect(dbl.foo("foobar") { nil }).to eq("bar")
      end
    end

    context "with common object methods" do
      Spectator::NullDouble.define(TestDouble) do
        stub abstract def hash(hasher)
      end

      let(stub) { Spectator::ValueStub.new(:hash, 12345, arguments).as(Spectator::Stub) }
      subject(dbl) { TestDouble.new([stub]) }

      it "returns the response when constraint satisfied" do
        expect(dbl.hash("foobar")).to eq(12345)
      end

      it "returns self when constraint unsatisfied" do
        expect(dbl.hash("baz")).to be(dbl)
      end

      it "returns self when argument count doesn't match" do
        expect(dbl.hash).to be(dbl)
      end
    end
  end

  describe "#_spectator_define_stub" do
    subject(dbl) { FooBarDouble.new }
    let(stub3) { Spectator::ValueStub.new(:foo, 3) }
    let(stub5) { Spectator::ValueStub.new(:foo, 5) }
    let(stub7) { Spectator::ValueStub.new(:foo, 7, Spectator::Arguments.capture(:lucky)) }

    it "overrides an existing method" do
      expect { dbl._spectator_define_stub(stub3) }.to change { dbl.foo }.from(42).to(3)
    end

    it "replaces an existing stub" do
      dbl._spectator_define_stub(stub3)
      expect { dbl._spectator_define_stub(stub5) }.to change { dbl.foo }.from(3).to(5)
    end

    it "doesn't affect other methods" do
      expect { dbl._spectator_define_stub(stub5) }.to_not change { dbl.bar }
    end

    it "picks the correct stub based on arguments" do
      dbl._spectator_define_stub(stub5)
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo).to eq(5)
        expect(dbl.foo(:lucky)).to eq(7)
      end
    end

    it "only uses a stub if an argument constraint is met" do
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo).to eq(42)
        expect(dbl.foo(:lucky)).to eq(7)
      end
    end

    it "ignores the block argument if not in the constraint" do
      dbl._spectator_define_stub(stub5)
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo { nil }).to eq(5)
        expect(dbl.foo(:lucky) { nil }).to eq(7)
      end
    end
  end
end
