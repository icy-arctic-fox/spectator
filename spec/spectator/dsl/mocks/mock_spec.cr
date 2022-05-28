require "../../../spec_helper"

Spectator.describe "Mock DSL", :smoke do
  context "with a concrete class" do
    class ConcreteClass
      def method1
        "original"
      end

      def method2 : Symbol
        :original
      end
    end

    context "specifying methods as keyword args" do
      mock(ConcreteClass, method1: "stubbed", method2: :stubbed)
      subject(fake) { mock(ConcreteClass) }

      it "defines a mock with methods" do
        aggregate_failures do
          expect(fake.method1).to eq("stubbed")
          expect(fake.method2).to eq(:stubbed)
        end
      end

      it "defines a subclass" do
        expect(fake).to be_a(ConcreteClass)
      end

      it "compiles types without unions" do
        aggregate_failures do
          expect(fake.method1).to compile_as(String)
          expect(fake.method2).to compile_as(Symbol)
        end
      end
    end
  end
end
