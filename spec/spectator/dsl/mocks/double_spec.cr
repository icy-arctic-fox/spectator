require "../../../spec_helper"

Spectator.describe "Double DSL" do
  context "specifying methods as keyword args" do
    double(:test, foo: "foobar", bar: 42)
    subject(dbl) { double(:test) }

    it "defines a double with methods" do
      aggregate_failures do
        expect(dbl.foo).to eq("foobar")
        expect(dbl.bar).to eq(42)
      end
    end

    it "compiles types without unions" do
      aggregate_failures do
        expect(dbl.foo).to compile_as(String)
        expect(dbl.bar).to compile_as(Int32)
      end
    end

    context "with an unexpected message" do
      it "raises an error" do
        expect { dbl.baz }.to raise_error(Spectator::UnexpectedMessage, /baz/)
      end

      it "reports the double name" do
        expect { dbl.baz }.to raise_error(Spectator::UnexpectedMessage, /:baz/)
      end

      it "reports the arguments" do
        expect { dbl.baz(:xyz, 123, a: "XYZ") }.to raise_error(Spectator::UnexpectedMessage, /\(:xyz, 123, a: "XYZ"\)/)
      end
    end
  end

  context "block with stubs" do
    context "one method" do
      double(:test2) do
        stub def foo
          "one method"
        end
      end

      subject(dbl) { double(:test2) }

      it "defines a double with methods" do
        expect(dbl.foo).to eq("one method")
      end

      it "compiles types without unions" do
        expect(dbl.foo).to compile_as(String)
      end
    end

    context "two methods" do
      double(:test3) do
        stub def foo
          "two methods"
        end

        stub def bar
          42
        end
      end

      subject(dbl) { double(:test3) }

      it "defines a double with methods" do
        aggregate_failures do
          expect(dbl.foo).to eq("two methods")
          expect(dbl.bar).to eq(42)
        end
      end

      it "compiles types without unions" do
        aggregate_failures do
          expect(dbl.foo).to compile_as(String)
          expect(dbl.bar).to compile_as(Int32)
        end
      end
    end

    context "empty block" do
      double(:test4) do
      end

      subject(dbl) { double(:test4) }

      it "defines a double" do
        expect(dbl).to be_a(Spectator::Double)
      end
    end

    context "stub-less method" do
      double(:test5) do
        def foo
          "no stub"
        end
      end

      subject(dbl) { double(:test5) }

      it "defines a double with methods" do
        expect(dbl.foo).to eq("no stub")
      end
    end
  end

  describe "double naming" do
    double(:Name, type: :symbol)

    it "accepts a symbolic double name" do
      dbl = double(:Name)
      expect(dbl.type).to eq(:symbol)
    end

    it "accepts a string double name" do
      dbl = double("Name")
      expect(dbl.type).to eq(:symbol)
    end

    it "accepts a constant double name" do
      dbl = double(Name)
      expect(dbl.type).to eq(:symbol)
    end
  end

  describe "scope" do
    double(:outer, scope: :outer)
    double(:scope, scope: :outer)

    it "finds a double in the same scope" do
      dbl = double(:outer)
      expect(dbl.scope).to eq(:outer)
    end

    it "uses an identically named double from the same scope" do
      dbl = double(:scope)
      expect(dbl.scope).to eq(:outer)
    end

    context "inner1" do
      double(:inner, scope: :inner1)
      double(:scope, scope: :inner1)

      it "finds a double in the same scope" do
        dbl = double(:inner)
        expect(dbl.scope).to eq(:inner1)
      end

      it "uses an identically named double from the same scope" do
        dbl = double(:scope)
        expect(dbl.scope).to eq(:inner1)
      end

      context "nested" do
        it "finds a double from a parent scope" do
          aggregate_failures do
            dbl = double(:inner)
            expect(dbl.scope).to eq(:inner1)
            dbl = double(:outer)
            expect(dbl.scope).to eq(:outer)
          end
        end

        it "uses the inner-most identically named double" do
          dbl = double(:inner)
          expect(dbl.scope).to eq(:inner1)
        end
      end
    end

    context "inner2" do
      double(:inner, scope: :inner2)
      double(:scope, scope: :inner2)

      it "finds a double in the same scope" do
        dbl = double(:inner)
        expect(dbl.scope).to eq(:inner2)
      end

      it "uses an identically named double from the same scope" do
        dbl = double(:scope)
        expect(dbl.scope).to eq(:inner2)
      end

      context "nested" do
        it "finds a double from a parent scope" do
          aggregate_failures do
            dbl = double(:inner)
            expect(dbl.scope).to eq(:inner2)
            dbl = double(:outer)
            expect(dbl.scope).to eq(:outer)
          end
        end

        it "uses the inner-most identically named double" do
          dbl = double(:inner)
          expect(dbl.scope).to eq(:inner2)
        end
      end
    end
  end
end
