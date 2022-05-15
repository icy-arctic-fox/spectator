require "../../spec_helper"

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

Spectator.describe Spectator::Mock do
  describe "#define_subclass" do
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

    Spectator::Mock.define_subclass(Thing, MockThing, :mock_name, method1: 123) do
      stub def method2
        :stubbed
      end
    end

    let(thing) { MockThing.new }

    it "defines a subclass of the mocked type" do
      expect(MockThing).to be_lt(Thing)
    end

    it "overrides responses from methods with keyword arguments" do
      expect(thing.method1).to eq(123)
    end

    it "overrides responses from methods defined in the block" do
      expect(thing.method2).to eq(:stubbed)
    end

    it "allows methods to be stubbed" do
      stub1 = Spectator::ValueStub.new(:method1, 777)
      stub2 = Spectator::ValueStub.new(:method2, :override)
      stub3 = Spectator::ValueStub.new(:method3, "stubbed")

      aggregate_failures do
        expect { thing._spectator_define_stub(stub1) }.to change { thing.method1 }.to(777)
        expect { thing._spectator_define_stub(stub2) }.to change { thing.method2 }.to(:override)
        expect { thing._spectator_define_stub(stub3) }.to change { thing.method3 }.from("original").to("stubbed")
      end
    end
  end

  describe "#inject" do
    # For some reason, `inject` can't find the types.
    # Their definitions are outside of the spec as a workaround.

    context "with a class" do
      Spectator::Mock.inject(MockedClass, :mock_name, method1: 123) do
        stub def method2
          :stubbed
        end
      end

      let(mock) { MockedClass.new }

      it "overrides responses from methods with keyword arguments" do
        expect(mock.method1).to eq(123)
      end

      it "overrides responses from methods defined in the block" do
        expect(mock.method2).to eq(:stubbed)
      end

      it "allows methods to be stubbed" do
        stub1 = Spectator::ValueStub.new(:method1, 777)
        stub2 = Spectator::ValueStub.new(:method2, :override)
        stub3 = Spectator::ValueStub.new(:method3, "stubbed")

        aggregate_failures do
          expect { mock._spectator_define_stub(stub1) }.to change { mock.method1 }.to(777)
          expect { mock._spectator_define_stub(stub2) }.to change { mock.method2 }.to(:override)
          expect { mock._spectator_define_stub(stub3) }.to change { mock.method3 }.from("original").to("stubbed")
        end
      end

      it "doesn't change the size of an instance" do
        expect(instance_sizeof(MockedClass)).to eq(8) # sizeof(Int32) + sizeof(TypeID)
      end

      it "doesn't affect instance variables" do
        expect(mock.instance_variables).to eq([:method1])
      end
    end

    context "with a struct" do
      Spectator::Mock.inject(MockedStruct, :mock_name, method1: 123) do
        stub def method2
          :stubbed
        end
      end

      let(mock) { MockedStruct.new }

      it "overrides responses from methods with keyword arguments" do
        expect(mock.method1).to eq(123)
      end

      it "overrides responses from methods defined in the block" do
        expect(mock.method2).to eq(:stubbed)
      end

      it "allows methods to be stubbed" do
        stub1 = Spectator::ValueStub.new(:method1, 777)
        stub2 = Spectator::ValueStub.new(:method2, :override)
        stub3 = Spectator::ValueStub.new(:method3, "stubbed")

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
    end
  end
end
