require "../../../spec_helper"

Spectator.describe "Mock DSL", :smoke do
  context "with a concrete class" do
    class ConcreteClass
      getter _spectator_calls = [] of Symbol

      def method1
        @_spectator_calls << :method1
        "original"
      end

      def method2 : Symbol
        @_spectator_calls << :method2
        :original
      end

      def method3(arg)
        @_spectator_calls << :method3
        arg
      end

      def method4 : Symbol
        yield
      end
    end

    context "specifying methods as keyword args" do
      mock(ConcreteClass, method1: "stubbed", method2: :stubbed, method4: :block)
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
        expect(fake._spectator_calls).to contain_exactly(:method3)
      end

      it "works with blocks" do
        expect(fake.method4 { :wrong }).to eq(:block)
      end
    end
  end

  context "with an abstract class" do
    abstract class AbstractClass
      getter _spectator_calls = [] of Symbol

      abstract def method1

      abstract def method2 : Symbol

      def method3(arg)
        @_spectator_calls << :method3
        arg
      end
    end

    context "specifying methods as keyword args" do
      mock(AbstractClass, method1: "stubbed", method2: :stubbed) do
        # NOTE: Abstract methods without a type restriction on the return value
        #   must be implemented with a type restriction.
        stub def method1 : String
          "stubbed"
        end
      end

      subject(fake) { mock(AbstractClass) }

      it "defines a mock with methods" do
        aggregate_failures do
          expect(fake.method1).to eq("stubbed")
          expect(fake.method2).to eq(:stubbed)
        end
      end

      it "defines a subclass" do
        expect(fake).to be_an(AbstractClass)
      end

      it "compiles types without unions" do
        aggregate_failures do
          expect(fake.method1).to compile_as(String)
          expect(fake.method2).to compile_as(Symbol)
        end
      end

      def restricted(thing : AbstractClass)
        thing.method1
      end

      it "can be used in type restricted methods" do
        expect(restricted(fake)).to eq("stubbed")
      end

      it "does not call the original method when stubbed" do
        fake.method1
        fake.method2
        fake.method3("foo")
        expect(fake._spectator_calls).to contain_exactly(:method3)
      end
    end
  end
end
