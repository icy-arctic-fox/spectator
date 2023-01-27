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
      expect { dbl.foo("bar") }.to raise_error(Spectator::UnexpectedMessage, /foo/)
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

  context "with a method that uses NoReturn" do
    Spectator::NullDouble.define(NoReturnDouble) do
      abstract_stub abstract def oops : NoReturn
    end

    subject(dbl) { NoReturnDouble.new }

    it "raises a TypeCastError when using a value-based stub" do
      stub = Spectator::ValueStub.new(:oops, nil).as(Spectator::Stub)
      dbl._spectator_define_stub(stub)
      expect { dbl.oops }.to raise_error(TypeCastError, /NoReturn/)
    end

    it "raises when using an exception stub" do
      exception = ArgumentError.new("bogus")
      stub = Spectator::ExceptionStub.new(:oops, exception).as(Spectator::Stub)
      dbl._spectator_define_stub(stub)
      expect { dbl.oops }.to raise_error(ArgumentError, "bogus")
    end
  end

  context "with common object methods" do
    subject(dbl) do
      EmptyDouble.new([
        Spectator::ValueStub.new(:"!=", false),
        Spectator::ValueStub.new(:"!~", false),
        Spectator::ValueStub.new(:"==", true),
        Spectator::ValueStub.new(:"===", true),
        Spectator::ValueStub.new(:"=~", nil),
        Spectator::ValueStub.new(:class, EmptyDouble),
        Spectator::ValueStub.new(:dup, EmptyDouble.new),
        Spectator::ValueStub.new(:"in?", true),
        Spectator::ValueStub.new(:inspect, "inspect"),
        Spectator::ValueStub.new(:itself, EmptyDouble.new),
        Spectator::ValueStub.new(:"not_nil!", EmptyDouble.new),
        Spectator::ValueStub.new(:pretty_inspect, "pretty_inspect"),
        Spectator::ValueStub.new(:tap, EmptyDouble.new),
        Spectator::ValueStub.new(:to_json, "to_json"),
        Spectator::ValueStub.new(:to_pretty_json, "to_pretty_json"),
        Spectator::ValueStub.new(:to_s, "to_s"),
        Spectator::ValueStub.new(:to_yaml, "to_yaml"),
        Spectator::ValueStub.new(:try, nil),
        Spectator::ValueStub.new(:object_id, 42_u64),
        Spectator::ValueStub.new(:"same?", true),
      ] of Spectator::Stub)
    end

    it "responds with defined messages" do
      aggregate_failures do
        expect(dbl.!=(42)).to be_false
        expect(dbl.!~(42)).to be_false
        expect(dbl.==(42)).to be_true
        expect(dbl.===(42)).to be_true
        expect(dbl.=~(42)).to be_nil
        expect(dbl.class).to eq(EmptyDouble)
        expect(dbl.dup).to be_a(EmptyDouble)
        expect(dbl.in?([42])).to eq(true)
        expect(dbl.in?(1, 2, 3)).to eq(true)
        expect(dbl.inspect).to eq("inspect")
        expect(dbl.itself).to be_a(EmptyDouble)
        expect(dbl.not_nil!).to be_a(EmptyDouble)
        expect(dbl.pretty_inspect).to eq("pretty_inspect")
        expect(dbl.tap { nil }).to be_a(EmptyDouble)
        expect(dbl.to_json).to eq("to_json")
        expect(dbl.to_pretty_json).to eq("to_pretty_json")
        expect(dbl.to_s).to eq("to_s")
        expect(dbl.to_yaml).to eq("to_yaml")
        expect(dbl.try { nil }).to be_nil
        expect(dbl.object_id).to eq(42_u64)
        expect(dbl.same?(dbl)).to be_true
        expect(dbl.same?(nil)).to be_true
      end
    end

    it "has a non-union return type" do
      expect(dbl.inspect).to compile_as(String)
    end
  end

  context "without common object methods" do
    subject(dbl) { EmptyDouble.new }

    it "returns original implementation with undefined messages" do
      hasher = Crystal::Hasher.new
      aggregate_failures do
        expect(dbl.!=(42)).to be_true
        expect(dbl.!~(42)).to be_true
        expect(dbl.==(42)).to be_false
        expect(dbl.===(42)).to be_false
        expect(dbl.=~(42)).to be_nil
        expect(dbl.class).to eq(EmptyDouble)
        expect(dbl.dup).to be_a(EmptyDouble)
        expect(dbl.hash(hasher)).to be_a(Crystal::Hasher)
        expect(dbl.hash).to be_a(UInt64)
        expect(dbl.in?([42])).to be_false
        expect(dbl.in?(1, 2, 3)).to be_false
        expect(dbl.itself).to be(dbl)
        expect(dbl.not_nil!).to be(dbl)
        expect(dbl.tap { nil }).to be(dbl)
        expect(dbl.try { nil }).to be_nil
        expect(dbl.object_id).to be_a(UInt64)
        expect(dbl.same?(dbl)).to be_true
        expect(dbl.same?(nil)).to be_false
      end
    end
  end

  context "with arguments constraints" do
    let(arguments) { Spectator::Arguments.capture(/foo/) }

    context "without common object methods" do
      Spectator::NullDouble.define(TestDouble) do
        abstract_stub abstract def foo(value) : String
        abstract_stub abstract def foo(value, & : -> _) : String
      end

      let(stub) { Spectator::ValueStub.new(:foo, "bar", arguments).as(Spectator::Stub) }
      subject(dbl) { TestDouble.new([stub]) }

      it "returns the response when constraint satisfied" do
        expect(dbl.foo("foobar")).to eq("bar")
      end

      it "raises when constraint unsatisfied" do
        expect { dbl.foo("baz") }.to raise_error(Spectator::UnexpectedMessage, /foo/)
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
        stub abstract def hash(hasher) : Crystal::Hasher
      end

      let(hasher) { Crystal::Hasher.new }
      let(stub) { Spectator::ValueStub.new(:hash, hasher, arguments).as(Spectator::Stub) }
      subject(dbl) { TestDouble.new([stub]) }

      it "returns the response when constraint satisfied" do
        expect(dbl.hash("foobar")).to be(hasher)
      end

      it "raises when constraint unsatisfied" do
        expect { dbl.hash("baz") }.to raise_error(Spectator::UnexpectedMessage, /hash/)
      end

      it "raises when argument count doesn't match" do
        expect { dbl.hash }.to raise_error(Spectator::UnexpectedMessage, /hash/)
      end
    end
  end

  context "class method stubs" do
    Spectator::NullDouble.define(ClassDouble) do
      stub def self.foo
        :stub
      end

      stub def self.bar(arg)
        arg
      end

      stub def self.baz(arg, &)
        yield
      end
    end

    subject(dbl) { ClassDouble }
    let(foo_stub) { Spectator::ValueStub.new(:foo, :override) }

    after { dbl._spectator_clear_stubs }

    it "overrides an existing method" do
      expect { dbl._spectator_define_stub(foo_stub) }.to change { dbl.foo }.from(:stub).to(:override)
    end

    it "doesn't affect other methods" do
      expect { dbl._spectator_define_stub(foo_stub) }.to_not change { dbl.bar(42) }
    end

    it "replaces an existing stub" do
      dbl._spectator_define_stub(foo_stub)
      stub = Spectator::ValueStub.new(:foo, :replacement)
      expect { dbl._spectator_define_stub(stub) }.to change { dbl.foo }.to(:replacement)
    end

    it "picks the correct stub based on arguments" do
      stub1 = Spectator::ValueStub.new(:bar, :fallback)
      stub2 = Spectator::ValueStub.new(:bar, :override, Spectator::Arguments.capture(:match))
      dbl._spectator_define_stub(stub1)
      dbl._spectator_define_stub(stub2)
      aggregate_failures do
        expect(dbl.bar(:wrong)).to eq(:fallback)
        expect(dbl.bar(:match)).to eq(:override)
      end
    end

    it "only uses a stub if an argument constraint is met" do
      stub = Spectator::ValueStub.new(:bar, :override, Spectator::Arguments.capture(:match))
      dbl._spectator_define_stub(stub)
      aggregate_failures do
        expect(dbl.bar(:original)).to eq(:original)
        expect(dbl.bar(:match)).to eq(:override)
      end
    end

    it "ignores the block argument if not in the constraint" do
      stub1 = Spectator::ValueStub.new(:baz, 1)
      stub2 = Spectator::ValueStub.new(:baz, 2, Spectator::Arguments.capture(3))
      dbl._spectator_define_stub(stub1)
      dbl._spectator_define_stub(stub2)
      aggregate_failures do
        expect(dbl.baz(5) { 42 }).to eq(1)
        expect(dbl.baz(3) { 42 }).to eq(2)
      end
    end

    describe "._spectator_clear_stubs" do
      before { dbl._spectator_define_stub(foo_stub) }

      it "removes previously defined stubs" do
        expect { dbl._spectator_clear_stubs }.to change { dbl.foo }.from(:override).to(:stub)
      end
    end

    describe "._spectator_calls" do
      before { dbl._spectator_clear_calls }

      # Retrieves symbolic names of methods called on a double.
      def called_method_names(dbl)
        dbl._spectator_calls.map(&.method)
      end

      it "stores calls to stubbed methods" do
        expect { dbl.foo }.to change { called_method_names(dbl) }.from(%i[]).to(%i[foo])
      end

      it "stores multiple calls to the same stub" do
        dbl.foo
        expect { dbl.foo }.to change { called_method_names(dbl) }.from(%i[foo]).to(%i[foo foo])
      end

      it "stores arguments for a call" do
        dbl.bar(42)
        args = Spectator::Arguments.capture(42)
        call = dbl._spectator_calls.first
        expect(call.arguments).to eq(args)
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

  describe "#_spectator_clear_stubs" do
    subject(dbl) { FooBarDouble.new }
    let(stub) { Spectator::ValueStub.new(:foo, 5) }

    before { dbl._spectator_define_stub(stub) }

    it "removes previously defined stubs" do
      expect { dbl._spectator_clear_stubs }.to change { dbl.foo }.from(5).to(42)
    end
  end

  describe "#_spectator_calls" do
    subject(dbl) { FooBarDouble.new }
    let(stub) { Spectator::ValueStub.new(:foo, 5) }

    before { dbl._spectator_define_stub(stub) }

    # Retrieves symbolic names of methods called on a double.
    def called_method_names(dbl)
      dbl._spectator_calls.map(&.method)
    end

    it "stores calls to stubbed methods" do
      expect { dbl.foo }.to change { called_method_names(dbl) }.from(%i[]).to(%i[foo])
    end

    it "stores multiple calls to the same stub" do
      dbl.foo
      expect { dbl.foo }.to change { called_method_names(dbl) }.from(%i[foo]).to(%i[foo foo])
    end

    it "stores calls to non-stubbed methods" do
      expect { dbl.baz }.to change { called_method_names(dbl) }.from(%i[]).to(%i[baz])
    end

    it "stores arguments for a call" do
      dbl.foo(42)
      args = Spectator::Arguments.capture(42)
      call = dbl._spectator_calls.first
      expect(call.arguments).to eq(args)
    end
  end

  describe "#to_s" do
    subject(string) { dbl.to_s }

    context "with a name" do
      let(dbl) { FooBarDouble.new }

      it "indicates it's a double" do
        expect(string).to contain("NullDouble")
      end

      it "contains the double name" do
        expect(string).to contain("dbl-name")
      end
    end

    context "without a name" do
      let(dbl) { EmptyDouble.new }

      it "contains the double type" do
        expect(string).to contain("NullDouble")
      end

      it "contains \"Anonymous\"" do
        expect(string).to contain("Anonymous")
      end
    end
  end

  describe "#inspect" do
    subject(string) { dbl.inspect }

    context "with a name" do
      let(dbl) { FooBarDouble.new }

      it "contains the double type" do
        expect(string).to contain("NullDouble")
      end

      it "contains the double name" do
        expect(string).to contain("dbl-name")
      end

      it "contains the object ID" do
        expect(string).to contain(dbl.object_id.to_s(16))
      end
    end

    context "without a name" do
      let(dbl) { EmptyDouble.new }

      it "contains the double type" do
        expect(string).to contain("NullDouble")
      end

      it "contains \"Anonymous\"" do
        expect(string).to contain("Anonymous")
      end

      it "contains the object ID" do
        expect(string).to contain(dbl.object_id.to_s(16))
      end
    end
  end
end
