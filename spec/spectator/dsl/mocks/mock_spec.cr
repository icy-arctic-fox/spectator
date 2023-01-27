require "../../../spec_helper"

Spectator.describe "Mock DSL", :smoke do
  alias CapturedArguments = Tuple(Int32, Tuple(Int32, Int32), Int32, NamedTuple(x: Int32, y: Int32, z: Int32))

  let(args_proc) do
    ->(args : Spectator::AbstractArguments) do
      {
        args[0].as(Int32),
        {
          args[1].as(Int32),
          args[2].as(Int32),
        },
        args[:kwarg].as(Int32),
        {
          x: args[:x].as(Int32),
          y: args[:y].as(Int32),
          z: args[:z].as(Int32),
        },
      }
    end
  end

  context "with a concrete class" do
    class ConcreteClass
      getter _spectator_invocations = [] of Symbol

      def method1
        @_spectator_invocations << :method1
        "original"
      end

      def method2 : Symbol
        @_spectator_invocations << :method2
        :original
      end

      def method3(arg)
        @_spectator_invocations << :method3
        arg
      end

      def method4(&) : Symbol
        @_spectator_invocations << :method4
        yield
      end

      def method5(&)
        @_spectator_invocations << :method5
        yield.to_i
      end

      def method6(&)
        @_spectator_invocations << :method6
        yield
      end

      def method7(arg, *args, kwarg, **kwargs)
        @_spectator_invocations << :method7
        {arg, args, kwarg, kwargs}
      end

      def method8(arg, *args, kwarg, **kwargs, &)
        @_spectator_invocations << :method8
        yield
        {arg, args, kwarg, kwargs}
      end
    end

    # method1 stubbed via mock block
    # method2 stubbed via keyword args
    # method3 not stubbed (calls original)
    # method4 stubbed via mock block (yields)
    # method5 stubbed via keyword args (yields)
    # method6 not stubbed (calls original and yields)
    # method7 not stubbed (calls original) testing args
    # method8 not stubbed (calls original and yields) testing args
    mock(ConcreteClass, method2: :stubbed, method5: 42) do
      stub def method1
        "stubbed"
      end

      stub def method4(&) : Symbol
        yield
        :block
      end
    end

    subject(fake) { mock(ConcreteClass) }

    it "defines a subclass" do
      expect(fake).to be_a(ConcreteClass)
    end

    it "defines stubs in the block" do
      expect(fake.method1).to eq("stubbed")
    end

    it "can stub methods defined in the block" do
      stub = Spectator::ValueStub.new(:method1, "override")
      expect { fake._spectator_define_stub(stub) }.to change { fake.method1 }.from("stubbed").to("override")
    end

    it "defines stubs from keyword arguments" do
      expect(fake.method2).to eq(:stubbed)
    end

    it "can stub methods from keyword arguments" do
      stub = Spectator::ValueStub.new(:method2, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method2 }.from(:stubbed).to(:override)
    end

    it "calls the original implementation for methods not provided a stub" do
      expect(fake.method3(:xyz)).to eq(:xyz)
    end

    it "can stub methods after declaration" do
      stub = Spectator::ValueStub.new(:method3, :abc)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method3(:xyz) }.from(:xyz).to(:abc)
    end

    it "defines stubs with yield in the block" do
      expect(fake.method4 { :wrong }).to eq(:block)
    end

    it "can stub methods with yield in the block" do
      stub = Spectator::ValueStub.new(:method4, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method4 { :wrong } }.from(:block).to(:override)
    end

    it "defines stubs with yield from keyword arguments" do
      expect(fake.method5 { :wrong }).to eq(42)
    end

    it "can stub methods with yield from keyword arguments" do
      stub = Spectator::ValueStub.new(:method5, 123)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method5 { "0" } }.from(42).to(123)
    end

    it "can stub yielding methods after declaration" do
      stub = Spectator::ValueStub.new(:method6, :abc)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method6 { :xyz } }.from(:xyz).to(:abc)
    end

    it "handles arguments correctly" do
      args1 = fake.method7(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7)
      args2 = fake.method8(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7) { :block }
      aggregate_failures do
        expect(args1).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
        expect(args2).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
      end
    end

    it "handles arguments correctly with stubs" do
      stub1 = Spectator::ProcStub.new(:method7, args_proc)
      stub2 = Spectator::ProcStub.new(:method8, args_proc)
      fake._spectator_define_stub(stub1)
      fake._spectator_define_stub(stub2)
      args1 = fake.method7(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7)
      args2 = fake.method8(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7) { :block }
      aggregate_failures do
        expect(args1).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
        expect(args2).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
      end
    end

    it "compiles types without unions" do
      aggregate_failures do
        expect(fake.method1).to compile_as(String)
        expect(fake.method2).to compile_as(Symbol)
        expect(fake.method3(42)).to compile_as(Int32)
        expect(fake.method4 { :foo }).to compile_as(Symbol)
        expect(fake.method5 { "123" }).to compile_as(Int32)
        expect(fake.method6 { "123" }).to compile_as(String)
      end
    end

    def restricted(thing : ConcreteClass)
      thing.method1
    end

    it "can be used in type restricted methods" do
      expect(restricted(fake)).to eq("stubbed")
    end

    it "does not call the original method when stubbed" do
      fake.method1
      fake.method2
      fake.method3("foo")
      fake.method4 { :foo }
      fake.method5 { "42" }
      fake.method6 { 42 }
      fake.method7(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7)
      fake.method8(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7) { :block }
      expect(fake._spectator_invocations).to contain_exactly(:method3, :method6, :method7, :method8)
    end

    # Cannot test unexpected messages - will not compile due to missing methods.

    describe "deferred default stubs" do
      mock(ConcreteClass)

      let(fake2) do
        mock(ConcreteClass,
          method1: "stubbed",
          method3: 123,
          method4: :xyz)
      end

      it "uses the keyword arguments as stubs" do
        aggregate_failures do
          expect(fake2.method1).to eq("stubbed")
          expect(fake2.method2).to eq(:original)
          expect(fake2.method3(42)).to eq(123)
          expect(fake2.method4 { :foo }).to eq(:xyz)
        end
      end
    end
  end

  context "with an abstract class" do
    abstract class AbstractClass
      abstract def method1

      abstract def method2 : Symbol

      abstract def method3 : Int32

      abstract def method4

      abstract def method5(&)

      abstract def method6(&) : Symbol

      abstract def method7(arg, *args, kwarg, **kwargs)

      abstract def method8(arg, *args, kwarg, **kwargs, &)
    end

    # method1 stubbed via mock block
    # method2 stubbed via keyword args
    # method3 not stubbed (raises)
    # method4 not stubbed, but type defined via mock block
    # method5 stubbed via mock block (yields)
    # method6 stubbed via keyword args (yields)
    # method7 not stubbed (calls original) testing args
    # method8 not stubbed (calls original and yields) testing args
    mock(AbstractClass, method2: :stubbed, method6: :kwargs) do
      # NOTE: Abstract methods without a type restriction on the return value
      #   must be implemented with a type restriction.
      stub def method1 : String
        "stubbed"
      end

      # NOTE: Defining the stub here with a return type restriction, but no default implementation.
      abstract_stub abstract def method4 : Symbol

      # NOTE: Abstract methods that yield must have yield functionality defined in the method.
      #   This requires that yielding methods have a default implementation.
      #   Just providing `&` in the arguments gets dropped by the compiler unless `yield` is in the method definition.
      stub def method5(&)
        yield
      end

      # NOTE: Another quirk where a default implementation must be provided because `&` is dropped.
      stub def method6(&) : Symbol
        yield
      end

      # NOTE: Defining the stub here with a return type restriction, but no default implementation.
      abstract_stub abstract def method7(arg, *args, kwarg, **kwargs) : CapturedArguments

      # NOTE: Another quirk where a default implementation must be provided because `&` is dropped.
      abstract_stub abstract def method8(arg, *args, kwarg, **kwargs, &) : CapturedArguments
    end

    subject(fake) { mock(AbstractClass) }

    it "defines a subclass" do
      expect(fake).to be_a(AbstractClass)
    end

    it "defines stubs in the block" do
      expect(fake.method1).to eq("stubbed")
    end

    it "can stub methods defined in the block" do
      stub = Spectator::ValueStub.new(:method1, "override")
      expect { fake._spectator_define_stub(stub) }.to change { fake.method1 }.from("stubbed").to("override")
    end

    it "defines stubs from keyword arguments" do
      expect(fake.method2).to eq(:stubbed)
    end

    it "can stub methods from keyword arguments" do
      stub = Spectator::ValueStub.new(:method2, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method2 }.from(:stubbed).to(:override)
    end

    it "raises on undefined stubs" do
      expect { fake.method3 }.to raise_error(Spectator::UnexpectedMessage, /method3/)
    end

    it "can defer stubs on previously undefined stubs" do
      stub = Spectator::ValueStub.new(:method3, 42)
      fake._spectator_define_stub(stub)
      expect(fake.method3).to eq(42)
    end

    it "raises on abstract stubs" do
      expect { fake.method4 }.to raise_error(Spectator::UnexpectedMessage, /method4/)
    end

    it "can defer stubs on abstract stubs" do
      stub = Spectator::ValueStub.new(:method4, :abstract)
      fake._spectator_define_stub(stub)
      expect(fake.method4).to eq(:abstract)
    end

    it "defines stubs with yield in the block" do
      stub = Spectator::ValueStub.new(:method5, :block)
      fake._spectator_define_stub(stub)
      expect(fake.method5 { :wrong }).to eq(:block)
    end

    it "defines stubs with yield from keyword arguments" do
      expect(fake.method6 { :wrong }).to eq(:kwargs)
    end

    it "can stub methods with yield from keyword arguments" do
      stub = Spectator::ValueStub.new(:method6, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method6 { :wrong } }.from(:kwargs).to(:override)
    end

    it "handles arguments correctly with stubs" do
      stub1 = Spectator::ProcStub.new(:method7, args_proc)
      stub2 = Spectator::ProcStub.new(:method8, args_proc)
      fake._spectator_define_stub(stub1)
      fake._spectator_define_stub(stub2)
      args1 = fake.method7(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7)
      args2 = fake.method8(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7) # { :block }
      aggregate_failures do
        expect(args1).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
        expect(args2).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
      end
    end

    it "compiles types without unions" do
      stub = Spectator::ValueStub.new(:method3, 42)
      fake._spectator_define_stub(stub)

      aggregate_failures do
        expect(fake.method1).to compile_as(String)
        expect(fake.method2).to compile_as(Symbol)
        expect(fake.method3).to compile_as(Int32)
        expect(fake.method5 { :foo }).to compile_as(Symbol)
        expect(fake.method6 { :foo }).to compile_as(Symbol)
      end
    end

    def restricted(thing : AbstractClass)
      thing.method1
    end

    it "can be used in type restricted methods" do
      expect(restricted(fake)).to eq("stubbed")
    end

    # Cannot test unexpected messages - will not compile due to missing methods.

    describe "deferred default stubs" do
      mock(AbstractClass) do
        # NOTE: Abstract methods without a type restriction on the return value
        #   must be implemented with a type restriction.
        abstract_stub abstract def method1 : String

        # NOTE: Defining the stub here with a return type restriction, but no default implementation.
        abstract_stub abstract def method4 : Symbol

        # NOTE: Abstract methods that yield must have yield functionality defined in the method.
        #   This requires that yielding methods have a default implementation.
        #   Just providing `&` in the arguments gets dropped by the compiler unless `yield` is in the method definition.
        stub def method5(&)
          yield
        end

        # NOTE: Another quirk where a default implementation must be provided because `&` is dropped.
        stub def method6(&) : Symbol
          yield
        end
      end

      let(fake2) do
        mock(AbstractClass,
          method1: "stubbed",
          method2: :stubbed,
          method3: 123,
          method4: :xyz,
          method5: :abc,
          method6: :bar)
      end

      it "uses the keyword arguments as stubs" do
        aggregate_failures do
          expect(fake2.method1).to eq("stubbed")
          expect(fake2.method2).to eq(:stubbed)
          expect(fake2.method3).to eq(123)
          expect(fake2.method4).to eq(:xyz)
          expect(fake2.method5 { :foo }).to eq(:abc)
          expect(fake2.method6 { :foo }).to eq(:bar)
        end
      end
    end
  end

  context "with an abstract struct" do
    abstract struct AbstractStruct
      abstract def method1

      abstract def method2 : Symbol

      abstract def method3 : Int32

      abstract def method4

      abstract def method5(&)

      abstract def method6(&) : Symbol

      abstract def method7(arg, *args, kwarg, **kwargs)

      abstract def method8(arg, *args, kwarg, **kwargs, &)
    end

    # method1 stubbed via mock block
    # method2 stubbed via keyword args
    # method3 not stubbed (raises)
    # method4 not stubbed, but type defined via mock block
    # method5 stubbed via mock block (yields)
    # method6 stubbed via keyword args (yields)
    # method7 not stubbed (calls original) testing args
    # method8 not stubbed (calls original and yields) testing args
    mock(AbstractStruct, method2: :stubbed, method6: :kwargs) do
      # NOTE: Abstract methods without a type restriction on the return value
      #   must be implemented with a type restriction.
      stub def method1 : String
        "stubbed"
      end

      # NOTE: Defining the stub here with a return type restriction, but no default implementation.
      abstract_stub abstract def method4 : Symbol

      # NOTE: Abstract methods that yield must have yield functionality defined in the method.
      #   This requires that yielding methods have a default implementation.
      #   Just providing `&` in the arguments gets dropped by the compiler unless `yield` is in the method definition.
      stub def method5(&)
        yield
      end

      # NOTE: Another quirk where a default implementation must be provided because `&` is dropped.
      stub def method6(&) : Symbol
        yield
      end

      # NOTE: Defining the stub here with a return type restriction, but no default implementation.
      abstract_stub abstract def method7(arg, *args, kwarg, **kwargs) : CapturedArguments

      # NOTE: Another quirk where a default implementation must be provided because `&` is dropped.
      abstract_stub abstract def method8(arg, *args, kwarg, **kwargs, &) : CapturedArguments
    end

    subject(fake) { mock(AbstractStruct) }

    it "defines a subtype" do
      expect(fake).to be_a(AbstractStruct)
    end

    it "defines stubs in the block" do
      expect(fake.method1).to eq("stubbed")
    end

    it "can stub methods defined in the block" do
      stub = Spectator::ValueStub.new(:method1, "override")
      expect { fake._spectator_define_stub(stub) }.to change { fake.method1 }.from("stubbed").to("override")
    end

    it "defines stubs from keyword arguments" do
      expect(fake.method2).to eq(:stubbed)
    end

    it "can stub methods from keyword arguments" do
      stub = Spectator::ValueStub.new(:method2, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method2 }.from(:stubbed).to(:override)
    end

    it "raises on undefined stubs" do
      expect { fake.method3 }.to raise_error(Spectator::UnexpectedMessage, /method3/)
    end

    it "can defer stubs on previously undefined stubs" do
      stub = Spectator::ValueStub.new(:method3, 42)
      fake._spectator_define_stub(stub)
      expect(fake.method3).to eq(42)
    end

    it "raises on abstract stubs" do
      expect { fake.method4 }.to raise_error(Spectator::UnexpectedMessage, /method4/)
    end

    it "can defer stubs on abstract stubs" do
      stub = Spectator::ValueStub.new(:method4, :abstract)
      fake._spectator_define_stub(stub)
      expect(fake.method4).to eq(:abstract)
    end

    it "defines stubs with yield in the block" do
      stub = Spectator::ValueStub.new(:method5, :block)
      fake._spectator_define_stub(stub)
      expect(fake.method5 { :wrong }).to eq(:block)
    end

    it "defines stubs with yield from keyword arguments" do
      expect(fake.method6 { :wrong }).to eq(:kwargs)
    end

    it "can stub methods with yield from keyword arguments" do
      stub = Spectator::ValueStub.new(:method6, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method6 { :wrong } }.from(:kwargs).to(:override)
    end

    it "handles arguments correctly with stubs" do
      stub1 = Spectator::ProcStub.new(:method7, args_proc)
      stub2 = Spectator::ProcStub.new(:method8, args_proc)
      fake._spectator_define_stub(stub1)
      fake._spectator_define_stub(stub2)
      args1 = fake.method7(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7)
      args2 = fake.method8(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7) # { :block }
      aggregate_failures do
        expect(args1).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
        expect(args2).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
      end
    end

    it "compiles types without unions" do
      stub = Spectator::ValueStub.new(:method3, 42)
      fake._spectator_define_stub(stub)

      aggregate_failures do
        expect(fake.method1).to compile_as(String)
        expect(fake.method2).to compile_as(Symbol)
        expect(fake.method3).to compile_as(Int32)
        expect(fake.method5 { :foo }).to compile_as(Symbol)
        expect(fake.method6 { :foo }).to compile_as(Symbol)
      end
    end

    def restricted(thing : AbstractStruct)
      thing.method1
    end

    it "can be used in type restricted methods" do
      expect(restricted(fake)).to eq("stubbed")
    end

    # Cannot test unexpected messages - will not compile due to missing methods.

    describe "deferred default stubs" do
      mock(AbstractStruct) do
        # NOTE: Abstract methods without a type restriction on the return value
        #   must be implemented with a type restriction.
        abstract_stub abstract def method1 : String

        # NOTE: Defining the stub here with a return type restriction, but no default implementation.
        abstract_stub abstract def method4 : Symbol

        # NOTE: Abstract methods that yield must have yield functionality defined in the method.
        #   This requires that yielding methods have a default implementation.
        #   Just providing `&` in the arguments gets dropped by the compiler unless `yield` is in the method definition.
        stub def method5(&)
          yield
        end

        # NOTE: Another quirk where a default implementation must be provided because `&` is dropped.
        stub def method6(&) : Symbol
          yield
        end
      end

      let(fake2) do
        mock(AbstractStruct,
          method1: "stubbed",
          method2: :stubbed,
          method3: 123,
          method4: :xyz,
          method5: :abc,
          method6: :bar)
      end

      it "uses the keyword arguments as stubs" do
        aggregate_failures do
          expect(fake2.method1).to eq("stubbed")
          expect(fake2.method2).to eq(:stubbed)
          expect(fake2.method3).to eq(123)
          expect(fake2.method4).to eq(:xyz)
          expect(fake2.method5 { :foo }).to eq(:abc)
          expect(fake2.method6 { :foo }).to eq(:bar)
        end
      end
    end
  end

  context "with a semi-abstract struct" do
    abstract struct SemiAbstractStruct
      def method1
        "original"
      end

      def method2 : Symbol
        :original
      end

      def method3(&)
        yield
      end

      def method4(&) : Int32
        yield.to_i
      end

      def method5
        42
      end
    end

    # method1 stubbed via mock block
    # method2 stubbed via keyword args
    # method3 not stubbed (calls original and yields)
    # method4 stubbed via keyword args (yields)
    # method5 not stubbed (calls original)
    mock(SemiAbstractStruct, method2: :stubbed, method4: 123) do
      stub def method1
        "stubbed"
      end
    end

    subject(fake) { mock(SemiAbstractStruct) }

    it "defines a subtype" do
      expect(fake).to be_a(SemiAbstractStruct)
    end

    it "defines stubs in the block" do
      expect(fake.method1).to eq("stubbed")
    end

    it "can stub methods defined in the block" do
      stub = Spectator::ValueStub.new(:method1, "override")
      expect { fake._spectator_define_stub(stub) }.to change { fake.method1 }.from("stubbed").to("override")
    end

    it "defines stubs from keyword arguments" do
      expect(fake.method2).to eq(:stubbed)
    end

    it "can stub methods from keyword arguments" do
      stub = Spectator::ValueStub.new(:method2, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method2 }.from(:stubbed).to(:override)
    end

    it "calls the original method with yielding methods" do
      expect(fake.method3 { :block }).to eq(:block)
    end

    it "can defer defining stubs with yielding methods" do
      stub = Spectator::ValueStub.new(:method3, :new)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method3 { :old } }.from(:old).to(:new)
    end

    it "defines stubs with yield from keyword arguments" do
      expect(fake.method4 { "42" }).to eq(123)
    end

    it "defines stubs with yield in the block" do
      stub = Spectator::ValueStub.new(:method4, 5)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method4 { "42" } }.from(123).to(5)
    end

    it "calls the original method" do
      expect(fake.method5).to eq(42)
    end

    it "can defer defining stubs" do
      stub = Spectator::ValueStub.new(:method5, 123)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method5 }.from(42).to(123)
    end

    it "compiles types without unions" do
      aggregate_failures do
        expect(fake.method1).to compile_as(String)
        expect(fake.method2).to compile_as(Symbol)
        expect(fake.method3 { :foo }).to compile_as(Symbol)
        expect(fake.method4 { "42" }).to compile_as(Int32)
        expect(fake.method5).to compile_as(Int32)
      end
    end

    def restricted(thing : SemiAbstractStruct)
      thing.method1
    end

    it "can be used in type restricted methods" do
      expect(restricted(fake)).to eq("stubbed")
    end

    # Cannot test unexpected messages - will not compile due to missing methods.

    describe "deferred default stubs" do
      mock(SemiAbstractStruct)

      let(fake2) do
        mock(SemiAbstractStruct,
          method1: "stubbed",
          method2: :stubbed,
          method3: :kwargs,
          method4: 123,
          method5: 0)
      end

      it "uses the keyword arguments as stubs" do
        aggregate_failures do
          expect(fake2.method1).to eq("stubbed")
          expect(fake2.method2).to eq(:stubbed)
          expect(fake2.method3 { :foo }).to eq(:kwargs)
          expect(fake2.method4 { "42" }).to eq(123)
          expect(fake2.method5).to eq(0)
        end
      end
    end
  end

  context "with a concrete struct" do
    struct ConcreteStruct
      def method1
        "original"
      end

      def method2 : Symbol
        :original
      end

      def method3(&)
        yield
      end

      def method4(&) : Int32
        yield.to_i
      end

      def method5
        42
      end
    end

    # method1 stubbed via mock block
    # method2 stubbed via keyword args
    # method3 not stubbed (calls original and yields)
    # method4 stubbed via keyword args (yields)
    # method5 not stubbed (calls original)
    inject_mock(ConcreteStruct, method2: :stubbed, method4: 123) do
      stub def method1
        "stubbed"
      end
    end

    subject(real) { mock(ConcreteStruct) }

    it "defines a subtype" do
      expect(real).to be_a(ConcreteStruct)
    end

    it "defines stubs in the block" do
      expect(real.method1).to eq("stubbed")
    end

    it "can stub methods defined in the block" do
      stub = Spectator::ValueStub.new(:method1, "override")
      expect { real._spectator_define_stub(stub) }.to change { real.method1 }.from("stubbed").to("override")
    end

    it "defines stubs from keyword arguments" do
      expect(real.method2).to eq(:stubbed)
    end

    it "can stub methods from keyword arguments" do
      stub = Spectator::ValueStub.new(:method2, :override)
      expect { real._spectator_define_stub(stub) }.to change { real.method2 }.from(:stubbed).to(:override)
    end

    it "calls the original method with yielding methods" do
      expect(real.method3 { :block }).to eq(:block)
    end

    it "can defer defining stubs with yielding methods" do
      stub = Spectator::ValueStub.new(:method3, :new)
      expect { real._spectator_define_stub(stub) }.to change { real.method3 { :old } }.from(:old).to(:new)
    end

    it "defines stubs with yield from keyword arguments" do
      expect(real.method4 { "42" }).to eq(123)
    end

    it "defines stubs with yield in the block" do
      stub = Spectator::ValueStub.new(:method4, 5)
      expect { real._spectator_define_stub(stub) }.to change { real.method4 { "42" } }.from(123).to(5)
    end

    it "calls the original method" do
      expect(real.method5).to eq(42)
    end

    it "can defer defining stubs" do
      stub = Spectator::ValueStub.new(:method5, 123)
      expect { real._spectator_define_stub(stub) }.to change { real.method5 }.from(42).to(123)
    end

    it "compiles types without unions" do
      aggregate_failures do
        expect(real.method1).to compile_as(String)
        expect(real.method2).to compile_as(Symbol)
        expect(real.method3 { :foo }).to compile_as(Symbol)
        expect(real.method4 { "42" }).to compile_as(Int32)
        expect(real.method5).to compile_as(Int32)
      end
    end

    def restricted(thing : ConcreteStruct)
      thing.method1
    end

    it "can be used in type restricted methods" do
      expect(restricted(real)).to eq("stubbed")
    end

    # Cannot test unexpected messages - will not compile due to missing methods.

    describe "deferred default stubs" do
      let(real) do
        mock(ConcreteStruct,
          method1: "stubbed",
          method2: :stubbed,
          method3: :kwargs,
          method4: 123,
          method5: 0)
      end

      it "uses the keyword arguments as stubs" do
        aggregate_failures do
          expect(real.method1).to eq("stubbed")
          expect(real.method2).to eq(:stubbed)
          expect(real.method3 { :foo }).to eq(:kwargs)
          expect(real.method4 { "42" }).to eq(123)
          expect(real.method5).to eq(0)
        end
      end
    end
  end

  describe "scope" do
    class Scope
      def scope
        :original
      end
    end

    mock(Scope, scope: :outer)

    it "finds a mock in the same scope" do
      fake = mock(Scope)
      expect(fake.scope).to eq(:outer)
    end

    context "inner1" do
      mock(Scope, scope: :inner)

      it "uses the innermost defined mock" do
        fake = mock(Scope)
        expect(fake.scope).to eq(:inner)
      end

      context "nested1" do
        mock(Scope, scope: :nested)

        it "uses the nested defined mock" do
          fake = mock(Scope)
          expect(fake.scope).to eq(:nested)
        end
      end

      context "nested2" do
        it "finds a mock from a parent scope" do
          fake = mock(Scope)
          expect(fake.scope).to eq(:inner)
        end
      end
    end

    context "inner2" do
      it "finds a mock from a parent scope" do
        fake = mock(Scope)
        expect(fake.scope).to eq(:outer)
      end

      context "nested3" do
        it "finds a mock from a grandparent scope" do
          fake = mock(Scope)
          expect(fake.scope).to eq(:outer)
        end
      end
    end
  end

  describe "context" do
    abstract class Dummy
      abstract def predefined : Symbol

      abstract def override : Symbol

      abstract def memoize : Symbol

      def inline : Symbol
        :original
      end

      def reference : String
        memoize.to_s
      end
    end

    mock(Dummy, predefined: :predefined, override: :predefined) do
      stub def inline : Symbol
        :inline # Memoized values can't be used here.
      end
    end

    let(memoize) { :memoize }
    let(override) { :override }
    let(fake) { mock(Dummy, override: override) }

    before { allow(fake).to receive(:memoize).and_return(memoize) }

    it "doesn't change predefined values" do
      expect(fake.predefined).to eq(:predefined)
    end

    it "can use memoized values for overrides" do
      expect(fake.override).to eq(:override)
    end

    it "can use memoized values for stubs" do
      expect(fake.memoize).to eq(:memoize)
    end

    it "can override inline stubs" do
      expect { allow(fake).to receive(:inline).and_return(override) }.to change { fake.inline }.from(:inline).to(:override)
    end

    it "can reference memoized values with indirection" do
      expect { allow(fake).to receive(:memoize).and_return(override) }.to change { fake.reference }.from("memoize").to("override")
    end
  end

  describe "class mock" do
    abstract class Dummy
      def self.abstract_method
        :not_really_abstract
      end

      def self.default_method
        :original
      end

      def self.args(arg)
        arg
      end

      def self.method1
        :original
      end

      def self.reference
        method1.to_s
      end
    end

    mock(Dummy) do
      abstract_stub def self.abstract_method
        :abstract
      end

      stub def self.default_method
        :default
      end
    end

    let(fake) { class_mock(Dummy) }

    it "raises on abstract stubs" do
      expect { fake.abstract_method }.to raise_error(Spectator::UnexpectedMessage, /abstract_method/)
    end

    it "can define default stubs" do
      expect(fake.default_method).to eq(:default)
    end

    it "can define new stubs" do
      expect { allow(fake).to receive(:args).and_return(42) }.to change { fake.args(5) }.from(5).to(42)
    end

    it "can override class method stubs" do
      allow(fake).to receive(:method1).and_return(:override)
      expect(fake.method1).to eq(:override)
    end

    it "can reference stubs" do
      allow(fake).to receive(:method1).and_return(:reference)
      expect(fake.reference).to eq("reference")
    end
  end

  describe "mock module" do
    module Dummy
      # `extend self` cannot be used.
      # The Crystal compiler doesn't report the methods as class methods when doing so.

      def self.abstract_method
        :not_really_abstract
      end

      def self.default_method
        :original
      end

      def self.args(arg)
        arg
      end

      def self.method1
        :original
      end

      def self.reference
        method1.to_s
      end
    end

    mock(Dummy) do
      abstract_stub def self.abstract_method
        :abstract
      end

      stub def self.default_method
        :default
      end
    end

    let(fake) { class_mock(Dummy) }

    it "raises on abstract stubs" do
      expect { fake.abstract_method }.to raise_error(Spectator::UnexpectedMessage, /abstract_method/)
    end

    it "can define default stubs" do
      expect(fake.default_method).to eq(:default)
    end

    it "can define new stubs" do
      expect { allow(fake).to receive(:args).and_return(42) }.to change { fake.args(5) }.from(5).to(42)
    end

    it "can override class method stubs" do
      allow(fake).to receive(:method1).and_return(:override)
      expect(fake.method1).to eq(:override)
    end

    xit "can reference stubs", pending: "Default stub of module class methods always refer to original" do
      allow(fake).to receive(:method1).and_return(:reference)
      expect(fake.reference).to eq("reference")
    end
  end

  context "with a class including a mocked module" do
    module Dummy
      getter _spectator_invocations = [] of Symbol

      def method1
        @_spectator_invocations << :method1
        "original"
      end

      def method2 : Symbol
        @_spectator_invocations << :method2
        :original
      end

      def method3(arg)
        @_spectator_invocations << :method3
        arg
      end

      def method4(&) : Symbol
        @_spectator_invocations << :method4
        yield
      end

      def method5(&)
        @_spectator_invocations << :method5
        yield.to_i
      end

      def method6(&)
        @_spectator_invocations << :method6
        yield
      end

      def method7(arg, *args, kwarg, **kwargs)
        @_spectator_invocations << :method7
        {arg, args, kwarg, kwargs}
      end

      def method8(arg, *args, kwarg, **kwargs, &)
        @_spectator_invocations << :method8
        yield
        {arg, args, kwarg, kwargs}
      end
    end

    # method1 stubbed via mock block
    # method2 stubbed via keyword args
    # method3 not stubbed (calls original)
    # method4 stubbed via mock block (yields)
    # method5 stubbed via keyword args (yields)
    # method6 not stubbed (calls original and yields)
    # method7 not stubbed (calls original) testing args
    # method8 not stubbed (calls original and yields) testing args
    mock(Dummy, method2: :stubbed, method5: 42) do
      stub def method1
        "stubbed"
      end

      stub def method4(&) : Symbol
        yield
        :block
      end
    end

    subject(fake) { mock(Dummy) }

    it "defines a subclass" do
      expect(fake).to be_a(Dummy)
    end

    it "defines stubs in the block" do
      expect(fake.method1).to eq("stubbed")
    end

    it "can stub methods defined in the block" do
      stub = Spectator::ValueStub.new(:method1, "override")
      expect { fake._spectator_define_stub(stub) }.to change { fake.method1 }.from("stubbed").to("override")
    end

    it "defines stubs from keyword arguments" do
      expect(fake.method2).to eq(:stubbed)
    end

    it "can stub methods from keyword arguments" do
      stub = Spectator::ValueStub.new(:method2, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method2 }.from(:stubbed).to(:override)
    end

    it "calls the original implementation for methods not provided a stub" do
      expect(fake.method3(:xyz)).to eq(:xyz)
    end

    it "can stub methods after declaration" do
      stub = Spectator::ValueStub.new(:method3, :abc)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method3(:xyz) }.from(:xyz).to(:abc)
    end

    it "defines stubs with yield in the block" do
      expect(fake.method4 { :wrong }).to eq(:block)
    end

    it "can stub methods with yield in the block" do
      stub = Spectator::ValueStub.new(:method4, :override)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method4 { :wrong } }.from(:block).to(:override)
    end

    it "defines stubs with yield from keyword arguments" do
      expect(fake.method5 { :wrong }).to eq(42)
    end

    it "can stub methods with yield from keyword arguments" do
      stub = Spectator::ValueStub.new(:method5, 123)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method5 { "0" } }.from(42).to(123)
    end

    it "can stub yielding methods after declaration" do
      stub = Spectator::ValueStub.new(:method6, :abc)
      expect { fake._spectator_define_stub(stub) }.to change { fake.method6 { :xyz } }.from(:xyz).to(:abc)
    end

    it "handles arguments correctly" do
      args1 = fake.method7(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7)
      args2 = fake.method8(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7) { :block }
      aggregate_failures do
        expect(args1).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
        expect(args2).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
      end
    end

    it "handles arguments correctly with stubs" do
      stub1 = Spectator::ProcStub.new(:method7, args_proc)
      stub2 = Spectator::ProcStub.new(:method8, args_proc)
      fake._spectator_define_stub(stub1)
      fake._spectator_define_stub(stub2)
      args1 = fake.method7(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7)
      args2 = fake.method8(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7) { :block }
      aggregate_failures do
        expect(args1).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
        expect(args2).to eq({1, {2, 3}, 4, {x: 5, y: 6, z: 7}})
      end
    end

    it "compiles types without unions" do
      aggregate_failures do
        expect(fake.method1).to compile_as(String)
        expect(fake.method2).to compile_as(Symbol)
        expect(fake.method3(42)).to compile_as(Int32)
        expect(fake.method4 { :foo }).to compile_as(Symbol)
        expect(fake.method5 { "123" }).to compile_as(Int32)
        expect(fake.method6 { "123" }).to compile_as(String)
      end
    end

    def restricted(thing : Dummy)
      thing.method1
    end

    it "can be used in type restricted methods" do
      expect(restricted(fake)).to eq("stubbed")
    end

    it "does not call the original method when stubbed" do
      fake.method1
      fake.method2
      fake.method3("foo")
      fake.method4 { :foo }
      fake.method5 { "42" }
      fake.method6 { 42 }
      fake.method7(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7)
      fake.method8(1, 2, 3, kwarg: 4, x: 5, y: 6, z: 7) { :block }
      expect(fake._spectator_invocations).to contain_exactly(:method3, :method6, :method7, :method8)
    end

    # Cannot test unexpected messages - will not compile due to missing methods.

    describe "deferred default stubs" do
      mock(Dummy)

      let(fake2) do
        mock(Dummy,
          method1: "stubbed",
          method3: 123,
          method4: :xyz)
      end

      it "uses the keyword arguments as stubs" do
        aggregate_failures do
          expect(fake2.method1).to eq("stubbed")
          expect(fake2.method2).to eq(:original)
          expect(fake2.method3(42)).to eq(123)
          expect(fake2.method4 { :foo }).to eq(:xyz)
        end
      end
    end
  end
end
