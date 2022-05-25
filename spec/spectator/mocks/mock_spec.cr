require "../../spec_helper"

Spectator.describe Spectator::Mock do
  let(stub1) { Spectator::ValueStub.new(:method1, 777) }
  let(stub2) { Spectator::ValueStub.new(:method2, :override) }
  let(stub3) { Spectator::ValueStub.new(:method3, "stubbed") }

  describe "#define_subtype" do
    context "with a concrete class" do
      class Thing
        def method1
          42
        end

        def method2
          :original
        end

        def method3
          "original"
        end
      end

      Spectator::Mock.define_subtype(:class, Thing, MockThing, :mock_name, method1: 123) do
        stub def method2
          :stubbed
        end
      end

      let(mock) { MockThing.new }

      it "defines a subclass of the mocked type" do
        expect(MockThing).to be_lt(Thing)
      end

      it "defines a class" do
        expect(MockThing).to be_lt(::Reference)
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
    end

    context "with an abstract class" do
      abstract class Thing
        abstract def method1

        abstract def method2 : Symbol

        def method3
          "original"
        end

        abstract def method4
      end

      Spectator::Mock.define_subtype(:class, Thing, MockThing, :mock_name, method2: :stubbed) do
        stub def method1 : Int32 # NOTE: Return type is required since one wasn't provided in the parent.
          123
        end
      end

      let(mock) { MockThing.new }

      it "defines a subclass of the mocked type" do
        expect(MockThing).to be_lt(Thing)
      end

      it "defines a class" do
        expect(MockThing).to be_lt(::Reference)
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
    end

    context "with an abstract struct" do
      abstract struct Thing
        abstract def method1

        abstract def method2 : Symbol

        def method3
          "original"
        end

        abstract def method4
      end

      Spectator::Mock.define_subtype(:struct, Thing, MockThing, :mock_name, method2: :stubbed) do
        stub def method1 : Int32 # NOTE: Return type is required since one wasn't provided in the parent.
          123
        end
      end

      let(mock) { MockThing.new }

      it "defines a sub-type of the mocked type" do
        expect(MockThing).to be_lt(Thing)
      end

      it "defines a struct" do
        expect(MockThing).to be_lt(::Value)
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
    end
  end

  describe "#inject" do
    context "with a class" do
      class MockedClass
        getter method1 = 42

        def method2
          :original
        end

        def method3
          "original"
        end

        def instance_variables
          [{{@type.instance_vars.map(&.name.symbolize).splat}}]
        end
      end

      Spectator::Mock.inject(:class, MockedClass, :mock_name, method1: 123) do
        stub def method2
          :stubbed
        end
      end

      let(mock) { MockedClass.new }

      # Necessary to clear stubs to prevent leakages between tests.
      after_each { mock._spectator_clear_stubs }

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
        expect(instance_sizeof(MockedClass)).to eq(8) # sizeof(Int32) + sizeof(TypeID)
      end

      it "doesn't affect instance variables" do
        expect(mock.instance_variables).to eq([:method1])
      end

      it "sets the mock name" do
        args = Spectator::Arguments.capture("foo")
        stub = Spectator::ValueStub.new(:method3, 0, args)
        mock._spectator_define_stub(stub)
        expect { mock.method3 }.to raise_error(Spectator::UnexpectedMessage, /mock_name/), "Raised error doesn't contain the mocked name."
      end
    end

    context "with a struct" do
      struct MockedStruct
        getter method1 = 42

        def method2
          :original
        end

        def method3
          "original"
        end

        def instance_variables
          [{{@type.instance_vars.map(&.name.symbolize).splat}}]
        end
      end

      Spectator::Mock.inject(:struct, MockedStruct, :mock_name, method1: 123) do
        stub def method2
          :stubbed
        end
      end

      let(mock) { MockedStruct.new }

      # Necessary to clear stubs to prevent leakages between tests.
      after_each { mock._spectator_clear_stubs }

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
        expect(sizeof(MockedStruct)).to eq(4) # sizeof(Int32)
      end

      it "doesn't affect instance variables" do
        expect(mock.instance_variables).to eq([:method1])
      end

      it "sets the mock name" do
        args = Spectator::Arguments.capture("foo")
        stub = Spectator::ValueStub.new(:method3, 0, args)
        mock._spectator_define_stub(stub)
        expect { mock.method3 }.to raise_error(Spectator::UnexpectedMessage, /mock_name/), "Raised error doesn't contain the mocked name."
      end
    end
  end
end
