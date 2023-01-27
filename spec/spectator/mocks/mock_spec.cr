require "../../spec_helper"

Spectator.describe Spectator::Mock do
  let(stub1) { Spectator::ValueStub.new(:method1, 777) }
  let(stub2) { Spectator::ValueStub.new(:method2, :override) }
  let(stub3) { Spectator::ValueStub.new(:method3, "stubbed") }

  # Retrieves symbolic names of methods called on a mock.
  def called_method_names(mock)
    mock._spectator_calls.map(&.method)
  end

  describe "#define_subtype" do
    context "with a concrete class" do
      class Thing
        getter _spectator_invocations = [] of Symbol

        def method1
          @_spectator_invocations << :method1
          42
        end

        def method2
          @_spectator_invocations << :method2
          :original
        end

        def method3
          @_spectator_invocations << :method3
          "original"
        end

        def method4 : Thing
          self
        end

        def method5 : OtherThing
          OtherThing.new
        end
      end

      class OtherThing; end

      Spectator::Mock.define_subtype(:class, Thing, MockThing, :mock_name, method1: 123) do
        stub def method2
          :stubbed
        end
      end

      let(mock) { MockThing.new }

      it "defines a subclass of the mocked type" do
        expect(mock).to be_a(Thing)
      end

      it "overrides responses from methods with keyword arguments" do
        expect(mock.method1).to eq(123)
      end

      it "overrides responses from methods defined in the block" do
        expect(mock.method2).to eq(:stubbed)
      end

      it "allows methods to be stubbed" do
        aggregate_failures do
          expect { mock._spectator_define_stub(stub1) }.to change { mock.method1 }.to(777)
          expect { mock._spectator_define_stub(stub2) }.to change { mock.method2 }.to(:override)
          expect { mock._spectator_define_stub(stub3) }.to change { mock.method3 }.from("original").to("stubbed")
        end
      end

      it "can clear stubs" do
        mock._spectator_define_stub(stub1)
        mock._spectator_define_stub(stub2)
        mock._spectator_define_stub(stub3)

        mock._spectator_clear_stubs
        aggregate_failures do
          expect(mock.method1).to eq(123)
          expect(mock.method2).to eq(:stubbed)
          expect(mock.method3).to eq("original")
        end
      end

      it "sets the mock name" do
        args = Spectator::Arguments.capture("foo")
        stub = Spectator::ValueStub.new(:method3, 0, args)
        mock._spectator_define_stub(stub)
        expect { mock.method3 }.to raise_error(Spectator::UnexpectedMessage, /mock_name/), "Raised error doesn't contain the mocked name."
      end

      it "records invoked stubs" do
        expect { mock.method2 }.to change { called_method_names(mock) }.from(%i[]).to(%i[method2])
        expect { mock.method1 }.to change { called_method_names(mock) }.from(%i[method2]).to(%i[method2 method1])
        expect { mock.method3 }.to change { called_method_names(mock) }.from(%i[method2 method1]).to(%i[method2 method1 method3])
      end

      it "records multiple invocations of the same stub" do
        mock.method2
        expect { mock.method2 }.to change { called_method_names(mock) }.from(%i[method2]).to(%i[method2 method2])
      end

      def restricted(thing : Thing)
        thing.method1
      end

      it "can be used in type restricted methods" do
        expect(restricted(mock)).to eq(123)
      end

      it "does not call the original method when stubbed" do
        mock.method1
        mock.method2
        mock.method3
        expect(mock._spectator_invocations).to contain_exactly(:method3)
      end

      it "can reference its own type" do
        new_mock = MockThing.new
        stub = Spectator::ValueStub.new(:method4, new_mock)
        mock._spectator_define_stub(stub)
        expect(mock.method4).to be(new_mock)
      end

      it "can reference other types in the original namespace" do
        other = OtherThing.new
        stub = Spectator::ValueStub.new(:method5, other)
        mock._spectator_define_stub(stub)
        expect(mock.method5).to be(other)
      end
    end

    context "with an abstract class" do
      abstract class Thing
        getter _spectator_invocations = [] of Symbol

        abstract def method1

        abstract def method2 : Symbol

        def method3
          @_spectator_invocations << :method3
          "original"
        end

        abstract def method4

        abstract def method4 : Thing

        abstract def method5 : OtherThing
      end

      class OtherThing; end

      Spectator::Mock.define_subtype(:class, Thing, MockThing, :mock_name, method2: :stubbed) do
        stub def method1 : Int32 # NOTE: Return type is required since one wasn't provided in the parent.
          123
        end
      end

      let(mock) { MockThing.new }

      it "defines a subclass of the mocked type" do
        expect(mock).to be_a(Thing)
      end

      it "overrides responses from methods defined in the block" do
        expect(mock.method1).to eq(123)
      end

      it "overrides responses from methods with keyword arguments" do
        expect(mock.method2).to eq(:stubbed)
      end

      it "allows methods to be stubbed" do
        aggregate_failures do
          expect { mock._spectator_define_stub(stub1) }.to change { mock.method1 }.to(777)
          expect { mock._spectator_define_stub(stub2) }.to change { mock.method2 }.to(:override)
          expect { mock._spectator_define_stub(stub3) }.to change { mock.method3 }.from("original").to("stubbed")
        end
      end

      it "can clear stubs" do
        mock._spectator_define_stub(stub1)
        mock._spectator_define_stub(stub2)
        mock._spectator_define_stub(stub3)

        mock._spectator_clear_stubs
        aggregate_failures do
          expect(mock.method1).to eq(123)
          expect(mock.method2).to eq(:stubbed)
          expect(mock.method3).to eq("original")
        end
      end

      it "raises when calling an abstract method that isn't stubbed" do
        expect { mock.method4 }.to raise_error(Spectator::UnexpectedMessage, /method4/)
      end

      it "sets the mock name" do
        args = Spectator::Arguments.capture("foo")
        stub = Spectator::ValueStub.new(:method3, 0, args)
        mock._spectator_define_stub(stub)
        expect { mock.method3 }.to raise_error(Spectator::UnexpectedMessage, /mock_name/), "Raised error doesn't contain the mocked name."
      end

      it "records invoked stubs" do
        expect { mock.method2 }.to change { called_method_names(mock) }.from(%i[]).to(%i[method2])
        expect { mock.method1 }.to change { called_method_names(mock) }.from(%i[method2]).to(%i[method2 method1])
        expect { mock.method3 }.to change { called_method_names(mock) }.from(%i[method2 method1]).to(%i[method2 method1 method3])
      end

      it "records multiple invocations of the same stub" do
        mock.method2
        expect { mock.method2 }.to change { called_method_names(mock) }.from(%i[method2]).to(%i[method2 method2])
      end

      def restricted(thing : Thing)
        thing.method1
      end

      it "can be used in type restricted methods" do
        expect(restricted(mock)).to eq(123)
      end

      it "does not call the original method when stubbed" do
        mock.method1
        mock.method2
        mock.method3
        expect(mock._spectator_invocations).to contain_exactly(:method3)
      end

      it "can reference its own type" do
        new_mock = MockThing.new
        stub = Spectator::ValueStub.new(:method4, new_mock)
        mock._spectator_define_stub(stub)
        expect(mock.method4).to be(new_mock)
      end

      it "can reference other types in the original namespace" do
        other = OtherThing.new
        stub = Spectator::ValueStub.new(:method5, other)
        mock._spectator_define_stub(stub)
        expect(mock.method5).to be(other)
      end
    end

    context "with an abstract struct" do
      abstract struct Thing
        getter _spectator_invocations = [] of Symbol

        abstract def method1

        abstract def method2 : Symbol

        def method3
          @_spectator_invocations << :method3
          "original"
        end

        abstract def method4

        abstract def method4 : Thing

        abstract def method5 : OtherThing
      end

      class OtherThing; end

      Spectator::Mock.define_subtype(:struct, Thing, MockThing, :mock_name, method2: :stubbed) do
        stub def method1 : Int32 # NOTE: Return type is required since one wasn't provided in the parent.
          123
        end
      end

      let(mock) { MockThing.new }

      it "defines a sub-type of the mocked type" do
        expect(mock).to be_a(Thing)
      end

      it "overrides responses from methods defined in the block" do
        expect(mock.method1).to eq(123)
      end

      it "overrides responses from methods with keyword arguments" do
        expect(mock.method2).to eq(:stubbed)
      end

      it "allows methods to be stubbed" do
        mock = self.mock # FIXME: Workaround for passing by value messing with stubs.
        aggregate_failures do
          expect { mock._spectator_define_stub(stub1) }.to change { mock.method1 }.to(777)
          expect { mock._spectator_define_stub(stub2) }.to change { mock.method2 }.to(:override)
          expect { mock._spectator_define_stub(stub3) }.to change { mock.method3 }.from("original").to("stubbed")
        end
      end

      it "can clear stubs" do
        mock._spectator_define_stub(stub1)
        mock._spectator_define_stub(stub2)
        mock._spectator_define_stub(stub3)

        mock._spectator_clear_stubs
        aggregate_failures do
          expect(mock.method1).to eq(123)
          expect(mock.method2).to eq(:stubbed)
          expect(mock.method3).to eq("original")
        end
      end

      it "raises when calling an abstract method that isn't stubbed" do
        expect { mock.method4 }.to raise_error(Spectator::UnexpectedMessage, /method4/)
      end

      it "sets the mock name" do
        mock = self.mock # FIXME: Workaround for passing by value messing with stubs.
        args = Spectator::Arguments.capture("foo")
        stub = Spectator::ValueStub.new(:method3, 0, args)
        mock._spectator_define_stub(stub)
        expect { mock.method3 }.to raise_error(Spectator::UnexpectedMessage, /mock_name/), "Raised error doesn't contain the mocked name."
      end

      def restricted(thing : Thing)
        thing.method1
      end

      it "can be used in type restricted methods" do
        expect(restricted(mock)).to eq(123)
      end

      it "does not call the original method when stubbed" do
        mock = self.mock # FIXME: Workaround for passing by value messing with stubs.
        mock.method1
        mock.method2
        mock.method3
        expect(mock._spectator_invocations).to contain_exactly(:method3)
      end

      it "can reference its own type" do
        mock = self.mock # FIXME: Workaround for passing by value messing with stubs.
        new_mock = MockThing.new
        stub = Spectator::ValueStub.new(:method4, new_mock)
        mock._spectator_define_stub(stub)
        expect(mock.method4).to be_a(Thing)
      end

      it "can reference other types in the original namespace" do
        mock = self.mock # FIXME: Workaround for passing by value messing with stubs.
        other = OtherThing.new
        stub = Spectator::ValueStub.new(:method5, other)
        mock._spectator_define_stub(stub)
        expect(mock.method5).to be(other)
      end
    end

    context "class method stubs" do
      class Thing
        def self.foo
          :original
        end

        def self.bar(arg)
          arg
        end

        def self.baz(arg, &)
          yield
        end

        def self.thing : Thing
          new
        end

        def self.other : OtherThing
          OtherThing.new
        end
      end

      class OtherThing; end

      Spectator::Mock.define_subtype(:class, Thing, MockThing) do
        stub def self.foo
          :stub
        end
      end

      let(mock) { MockThing }
      let(foo_stub) { Spectator::ValueStub.new(:foo, :override) }

      after { mock._spectator_clear_stubs }

      it "overrides an existing method" do
        expect { mock._spectator_define_stub(foo_stub) }.to change { mock.foo }.from(:stub).to(:override)
      end

      it "doesn't affect other methods" do
        expect { mock._spectator_define_stub(foo_stub) }.to_not change { mock.bar(42) }
      end

      it "replaces an existing stub" do
        mock._spectator_define_stub(foo_stub)
        stub = Spectator::ValueStub.new(:foo, :replacement)
        expect { mock._spectator_define_stub(stub) }.to change { mock.foo }.to(:replacement)
      end

      it "picks the correct stub based on arguments" do
        stub1 = Spectator::ValueStub.new(:bar, :fallback)
        stub2 = Spectator::ValueStub.new(:bar, :override, Spectator::Arguments.capture(:match))
        mock._spectator_define_stub(stub1)
        mock._spectator_define_stub(stub2)
        aggregate_failures do
          expect(mock.bar(:wrong)).to eq(:fallback)
          expect(mock.bar(:match)).to eq(:override)
        end
      end

      it "only uses a stub if an argument constraint is met" do
        stub = Spectator::ValueStub.new(:bar, :override, Spectator::Arguments.capture(:match))
        mock._spectator_define_stub(stub)
        aggregate_failures do
          expect(mock.bar(:original)).to eq(:original)
          expect(mock.bar(:match)).to eq(:override)
        end
      end

      it "ignores the block argument if not in the constraint" do
        stub1 = Spectator::ValueStub.new(:baz, 1)
        stub2 = Spectator::ValueStub.new(:baz, 2, Spectator::Arguments.capture(3))
        mock._spectator_define_stub(stub1)
        mock._spectator_define_stub(stub2)
        aggregate_failures do
          expect(mock.baz(5) { 42 }).to eq(1)
          expect(mock.baz(3) { 42 }).to eq(2)
        end
      end

      def restricted(thing : Thing.class)
        thing.foo
      end

      it "can be used in type restricted methods" do
        expect(restricted(mock)).to eq(:stub)
      end

      it "can reference its own type" do
        new_mock = MockThing.new
        stub = Spectator::ValueStub.new(:thing, new_mock)
        mock._spectator_define_stub(stub)
        expect(mock.thing).to be(new_mock)
      end

      it "can reference other types in the original namespace" do
        other = OtherThing.new
        stub = Spectator::ValueStub.new(:other, other)
        mock._spectator_define_stub(stub)
        expect(mock.other).to be(other)
      end

      describe "._spectator_clear_stubs" do
        before { mock._spectator_define_stub(foo_stub) }

        it "removes previously defined stubs" do
          expect { mock._spectator_clear_stubs }.to change { mock.foo }.from(:override).to(:stub)
        end
      end

      describe "._spectator_calls" do
        before { mock._spectator_clear_calls }

        # Retrieves symbolic names of methods called on a mock.
        def called_method_names(mock)
          mock._spectator_calls.map(&.method)
        end

        it "stores calls to stubbed methods" do
          expect { mock.foo }.to change { called_method_names(mock) }.from(%i[]).to(%i[foo])
        end

        it "stores multiple calls to the same stub" do
          mock.foo
          expect { mock.foo }.to change { called_method_names(mock) }.from(%i[foo]).to(%i[foo foo])
        end

        it "stores arguments for a call" do
          mock.bar(42)
          args = Spectator::Arguments.capture(42)
          call = mock._spectator_calls.first
          expect(call.arguments).to eq(args)
        end
      end
    end

    context "with a module" do
      module Thing
        # `extend self` cannot be used.
        # The Crystal compiler doesn't report the methods as class methods when doing so.

        def self.original_method
          :original
        end

        def self.default_method
          :original
        end

        def self.stubbed_method(_value = 42)
          :original
        end
      end

      Spectator::Mock.define_subtype(:module, Thing, MockThing) do
        stub def self.stubbed_method(_value = 42)
          :stubbed
        end
      end

      let(mock) { MockThing }

      after { mock._spectator_clear_stubs }

      it "overrides an existing method" do
        stub = Spectator::ValueStub.new(:original_method, :override)
        expect { mock._spectator_define_stub(stub) }.to change { mock.original_method }.from(:original).to(:override)
      end

      it "doesn't affect other methods" do
        stub = Spectator::ValueStub.new(:stubbed_method, :override)
        expect { mock._spectator_define_stub(stub) }.to_not change { mock.original_method }
      end

      it "replaces an existing default stub" do
        stub = Spectator::ValueStub.new(:default_method, :override)
        expect { mock._spectator_define_stub(stub) }.to change { mock.default_method }.to(:override)
      end

      it "replaces an existing stubbed method" do
        stub = Spectator::ValueStub.new(:stubbed_method, :override)
        expect { mock._spectator_define_stub(stub) }.to change { mock.stubbed_method }.to(:override)
      end

      def restricted(thing : Thing.class)
        thing.stubbed_method
      end

      it "can be used in type restricted methods" do
        expect(restricted(mock)).to eq(:stubbed)
      end

      describe "._spectator_clear_stubs" do
        before do
          stub = Spectator::ValueStub.new(:original_method, :override)
          mock._spectator_define_stub(stub)
        end

        it "removes previously defined stubs" do
          expect { mock._spectator_clear_stubs }.to change { mock.original_method }.from(:override).to(:original)
        end
      end

      describe "._spectator_calls" do
        before { mock._spectator_clear_calls }

        # Retrieves symbolic names of methods called on a mock.
        def called_method_names(mock)
          mock._spectator_calls.map(&.method)
        end

        it "stores calls to original methods" do
          expect { mock.original_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[original_method])
        end

        it "stores calls to default methods" do
          expect { mock.default_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[default_method])
        end

        it "stores calls to stubbed methods" do
          expect { mock.stubbed_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[stubbed_method])
        end

        it "stores multiple calls to the same stub" do
          mock.stubbed_method
          expect { mock.stubbed_method }.to change { called_method_names(mock) }.from(%i[stubbed_method]).to(%i[stubbed_method stubbed_method])
        end

        it "stores arguments for a call" do
          mock.stubbed_method(5)
          args = Spectator::Arguments.capture(5)
          call = mock._spectator_calls.first
          expect(call.arguments).to eq(args)
        end
      end
    end

    context "with a mocked module included in a class" do
      module Thing
        def original_method
          :original
        end

        def default_method
          :original
        end

        def stubbed_method(_value = 42)
          :original
        end
      end

      Spectator::Mock.define_subtype(:module, Thing, MockThing, default_method: :default) do
        stub def stubbed_method(_value = 42)
          :stubbed
        end
      end

      class IncludedMock
        include MockThing
      end

      let(mock) { IncludedMock.new }

      it "overrides an existing method" do
        stub = Spectator::ValueStub.new(:original_method, :override)
        expect { mock._spectator_define_stub(stub) }.to change { mock.original_method }.from(:original).to(:override)
      end

      it "doesn't affect other methods" do
        stub = Spectator::ValueStub.new(:stubbed_method, :override)
        expect { mock._spectator_define_stub(stub) }.to_not change { mock.original_method }
      end

      it "replaces an existing default stub" do
        stub = Spectator::ValueStub.new(:default_method, :override)
        expect { mock._spectator_define_stub(stub) }.to change { mock.default_method }.to(:override)
      end

      it "replaces an existing stubbed method" do
        stub = Spectator::ValueStub.new(:stubbed_method, :override)
        expect { mock._spectator_define_stub(stub) }.to change { mock.stubbed_method }.to(:override)
      end

      def restricted(thing : Thing.class)
        thing.default_method
      end

      describe "#_spectator_clear_stubs" do
        before do
          stub = Spectator::ValueStub.new(:original_method, :override)
          mock._spectator_define_stub(stub)
        end

        it "removes previously defined stubs" do
          expect { mock._spectator_clear_stubs }.to change { mock.original_method }.from(:override).to(:original)
        end
      end

      describe "#_spectator_calls" do
        before { mock._spectator_clear_calls }

        # Retrieves symbolic names of methods called on a mock.
        def called_method_names(mock)
          mock._spectator_calls.map(&.method)
        end

        it "stores calls to original methods" do
          expect { mock.original_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[original_method])
        end

        it "stores calls to default methods" do
          expect { mock.default_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[default_method])
        end

        it "stores calls to stubbed methods" do
          expect { mock.stubbed_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[stubbed_method])
        end

        it "stores multiple calls to the same stub" do
          mock.stubbed_method
          expect { mock.stubbed_method }.to change { called_method_names(mock) }.from(%i[stubbed_method]).to(%i[stubbed_method stubbed_method])
        end

        it "stores arguments for a call" do
          mock.stubbed_method(5)
          args = Spectator::Arguments.capture(5)
          call = mock._spectator_calls.first
          expect(call.arguments).to eq(args)
        end
      end
    end

    context "with a method that uses NoReturn" do
      abstract class Thing
        abstract def oops : NoReturn
      end

      Spectator::Mock.define_subtype(:class, Thing, MockThing)

      let(mock) { MockThing.new }

      after { mock._spectator_clear_stubs }

      it "raises a TypeCastError when using a value-based stub" do
        stub = Spectator::ValueStub.new(:oops, nil).as(Spectator::Stub)
        mock._spectator_define_stub(stub)
        expect { mock.oops }.to raise_error(TypeCastError, /NoReturn/)
      end

      it "raises when using an exception stub" do
        exception = ArgumentError.new("bogus")
        stub = Spectator::ExceptionStub.new(:oops, exception).as(Spectator::Stub)
        mock._spectator_define_stub(stub)
        expect { mock.oops }.to raise_error(ArgumentError, "bogus")
      end
    end
  end

  describe "#inject" do
    context "with a class" do
      class ::MockedClass
        getter _spectator_invocations = [] of Symbol

        getter method1 do
          @_spectator_invocations << :method1
          42
        end

        def method2
          @_spectator_invocations << :method2
          :original
        end

        def method3
          @_spectator_invocations << :method3
          "original"
        end

        def instance_variables
          {% begin %}[{{@type.instance_vars.map(&.name.symbolize).splat}}]{% end %}
        end
      end

      Spectator::Mock.inject(:class, ::MockedClass, :mock_name, method1: 123) do
        stub def method2
          :stubbed
        end
      end

      let(mock) { MockedClass.new }

      # Necessary to clear stubs to prevent leakages between tests.
      after { mock._spectator_clear_stubs }

      it "overrides responses from methods with keyword arguments" do
        expect(mock.method1).to eq(123)
      end

      it "overrides responses from methods defined in the block" do
        expect(mock.method2).to eq(:stubbed)
      end

      it "allows methods to be stubbed" do
        aggregate_failures do
          expect { mock._spectator_define_stub(stub1) }.to change { mock.method1 }.to(777)
          expect { mock._spectator_define_stub(stub2) }.to change { mock.method2 }.to(:override)
          expect { mock._spectator_define_stub(stub3) }.to change { mock.method3 }.from("original").to("stubbed")
        end
      end

      it "can clear stubs" do
        mock._spectator_define_stub(stub1)
        mock._spectator_define_stub(stub2)
        mock._spectator_define_stub(stub3)

        mock._spectator_clear_stubs
        aggregate_failures do
          expect(mock.method1).to eq(123)
          expect(mock.method2).to eq(:stubbed)
          expect(mock.method3).to eq("original")
        end
      end

      it "doesn't change the size of an instance" do
        size = sizeof(Int64) + sizeof(Int32?) + sizeof(Array(Symbol)) # TypeID + Int32? + _spectator_invocations
        expect(instance_sizeof(MockedClass)).to eq(size)
      end

      it "doesn't affect instance variables" do
        expect(mock.instance_variables).to contain_exactly(:method1, :_spectator_invocations)
      end

      it "sets the mock name" do
        args = Spectator::Arguments.capture("foo")
        stub = Spectator::ValueStub.new(:method3, 0, args)
        mock._spectator_define_stub(stub)
        expect { mock.method3 }.to raise_error(Spectator::UnexpectedMessage, /mock_name/), "Raised error doesn't contain the mocked name."
      end

      it "records invoked stubs" do
        expect { mock.method2 }.to change { called_method_names(mock) }.from(%i[]).to(%i[method2])
        expect { mock.method1 }.to change { called_method_names(mock) }.from(%i[method2]).to(%i[method2 method1])
        expect { mock.method3 }.to change { called_method_names(mock) }.from(%i[method2 method1]).to(%i[method2 method1 method3])
      end

      it "records multiple invocations of the same stub" do
        mock.method2
        expect { mock.method2 }.to change { called_method_names(mock) }.from(%i[method2]).to(%i[method2 method2])
      end

      def restricted(thing : MockedClass)
        thing.method1
      end

      it "can be used in type restricted methods" do
        expect(restricted(mock)).to eq(123)
      end

      it "does not call the original method when stubbed" do
        mock.method1
        mock.method2
        mock.method3
        expect(mock._spectator_invocations).to contain_exactly(:method3)
      end
    end

    context "with a struct" do
      struct ::MockedStruct
        # Using a class variable instead of an instance variable to prevent mutability problems with stub lookup.
        class_getter _spectator_invocations = [] of Symbol

        @method1 = 42

        def method1
          @@_spectator_invocations << :method1
          @method1
        end

        def method2
          @@_spectator_invocations << :method2
          :original
        end

        def method3
          @@_spectator_invocations << :method3
          "original"
        end

        def instance_variables
          {% begin %}[{{@type.instance_vars.map(&.name.symbolize).splat}}]{% end %}
        end
      end

      Spectator::Mock.inject(:struct, ::MockedStruct, :mock_name, method1: 123) do
        stub def method2
          :stubbed
        end
      end

      let(mock) { MockedStruct.new }

      # Necessary to clear stubs to prevent leakages between tests.
      after { mock._spectator_clear_stubs }
      after { MockedStruct._spectator_invocations.clear }

      it "overrides responses from methods with keyword arguments" do
        expect(mock.method1).to eq(123)
      end

      it "overrides responses from methods defined in the block" do
        expect(mock.method2).to eq(:stubbed)
      end

      it "allows methods to be stubbed" do
        aggregate_failures do
          expect { mock._spectator_define_stub(stub1) }.to change { mock.method1 }.to(777)
          expect { mock._spectator_define_stub(stub2) }.to change { mock.method2 }.to(:override)
          expect { mock._spectator_define_stub(stub3) }.to change { mock.method3 }.from("original").to("stubbed")
        end
      end

      it "doesn't change the size of an instance" do
        expect(sizeof(MockedStruct)).to eq(sizeof(Int32))
      end

      it "doesn't affect instance variables" do
        expect(mock.instance_variables).to contain_exactly(:method1)
      end

      it "sets the mock name" do
        args = Spectator::Arguments.capture("foo")
        stub = Spectator::ValueStub.new(:method3, 0, args)
        mock._spectator_define_stub(stub)
        expect { mock.method3 }.to raise_error(Spectator::UnexpectedMessage, /mock_name/), "Raised error doesn't contain the mocked name."
      end

      it "records invoked stubs" do
        expect { mock.method2 }.to change { called_method_names(mock) }.from(%i[]).to(%i[method2])
        expect { mock.method1 }.to change { called_method_names(mock) }.from(%i[method2]).to(%i[method2 method1])
        expect { mock.method3 }.to change { called_method_names(mock) }.from(%i[method2 method1]).to(%i[method2 method1 method3])
      end

      it "records multiple invocations of the same stub" do
        mock.method2
        expect { mock.method2 }.to change { called_method_names(mock) }.from(%i[method2]).to(%i[method2 method2])
      end

      def restricted(thing : MockedStruct)
        thing.method1
      end

      it "can be used in type restricted methods" do
        expect(restricted(mock)).to eq(123)
      end

      it "does not call the original method when stubbed" do
        mock.method1
        mock.method2
        mock.method3
        expect(MockedStruct._spectator_invocations).to contain_exactly(:method3)
      end
    end

    context "class method stubs" do
      class ::Thing
        def self.foo
          :original
        end

        def self.bar(arg)
          arg
        end

        def self.baz(arg, &)
          yield
        end
      end

      Spectator::Mock.inject(:class, ::Thing) do
        stub def self.foo
          :stub
        end
      end

      let(mock) { Thing }
      let(foo_stub) { Spectator::ValueStub.new(:foo, :override) }

      after { mock._spectator_clear_stubs }

      it "overrides an existing method" do
        expect { mock._spectator_define_stub(foo_stub) }.to change { mock.foo }.from(:stub).to(:override)
      end

      it "doesn't affect other methods" do
        expect { mock._spectator_define_stub(foo_stub) }.to_not change { mock.bar(42) }
      end

      it "replaces an existing stub" do
        mock._spectator_define_stub(foo_stub)
        stub = Spectator::ValueStub.new(:foo, :replacement)
        expect { mock._spectator_define_stub(stub) }.to change { mock.foo }.to(:replacement)
      end

      it "picks the correct stub based on arguments" do
        stub1 = Spectator::ValueStub.new(:bar, :fallback)
        stub2 = Spectator::ValueStub.new(:bar, :override, Spectator::Arguments.capture(:match))
        mock._spectator_define_stub(stub1)
        mock._spectator_define_stub(stub2)
        aggregate_failures do
          expect(mock.bar(:wrong)).to eq(:fallback)
          expect(mock.bar(:match)).to eq(:override)
        end
      end

      it "only uses a stub if an argument constraint is met" do
        stub = Spectator::ValueStub.new(:bar, :override, Spectator::Arguments.capture(:match))
        mock._spectator_define_stub(stub)
        aggregate_failures do
          expect(mock.bar(:original)).to eq(:original)
          expect(mock.bar(:match)).to eq(:override)
        end
      end

      it "ignores the block argument if not in the constraint" do
        stub1 = Spectator::ValueStub.new(:baz, 1)
        stub2 = Spectator::ValueStub.new(:baz, 2, Spectator::Arguments.capture(3))
        mock._spectator_define_stub(stub1)
        mock._spectator_define_stub(stub2)
        aggregate_failures do
          expect(mock.baz(5) { 42 }).to eq(1)
          expect(mock.baz(3) { 42 }).to eq(2)
        end
      end

      def restricted(thing : Thing.class)
        thing.foo
      end

      it "can be used in type restricted methods" do
        expect(restricted(mock)).to eq(:stub)
      end

      describe "._spectator_clear_stubs" do
        before { mock._spectator_define_stub(foo_stub) }

        it "removes previously defined stubs" do
          expect { mock._spectator_clear_stubs }.to change { mock.foo }.from(:override).to(:stub)
        end
      end

      describe "._spectator_calls" do
        before { mock._spectator_clear_calls }

        # Retrieves symbolic names of methods called on a mock.
        def called_method_names(mock)
          mock._spectator_calls.map(&.method)
        end

        it "stores calls to stubbed methods" do
          expect { mock.foo }.to change { called_method_names(mock) }.from(%i[]).to(%i[foo])
        end

        it "stores multiple calls to the same stub" do
          mock.foo
          expect { mock.foo }.to change { called_method_names(mock) }.from(%i[foo]).to(%i[foo foo])
        end

        it "stores arguments for a call" do
          mock.bar(42)
          args = Spectator::Arguments.capture(42)
          call = mock._spectator_calls.first
          expect(call.arguments).to eq(args)
        end
      end
    end

    context "with a method that uses NoReturn" do
      struct ::NoReturnThing
        def oops : NoReturn
          raise "oops"
        end
      end

      Spectator::Mock.inject(:struct, ::NoReturnThing)

      let(mock) { NoReturnThing.new }

      after { mock._spectator_clear_stubs }

      it "raises a TypeCastError when using a value-based stub" do
        stub = Spectator::ValueStub.new(:oops, nil).as(Spectator::Stub)
        mock._spectator_define_stub(stub)
        expect { mock.oops }.to raise_error(TypeCastError, /NoReturn/)
      end

      it "raises when using an exception stub" do
        exception = ArgumentError.new("bogus")
        stub = Spectator::ExceptionStub.new(:oops, exception).as(Spectator::Stub)
        mock._spectator_define_stub(stub)
        expect { mock.oops }.to raise_error(ArgumentError, "bogus")
      end
    end
  end
end
