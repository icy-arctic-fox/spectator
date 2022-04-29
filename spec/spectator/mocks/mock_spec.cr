require "../../spec_helper"

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
end
