require "../../../spec_helper"

Spectator.describe "Double DSL", :smoke do
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
        expect { dbl.baz }.to raise_error(Spectator::UnexpectedMessage, /:test/)
      end

      it "reports the arguments" do
        expect { dbl.baz(:xyz, 123, a: "XYZ") }.to raise_error(Spectator::UnexpectedMessage, /\(:xyz, 123, a: "XYZ"\)/)
      end
    end

    context "blocks" do
      it "supports blocks" do
        aggregate_failures do
          expect(dbl.foo { nil }).to eq("foobar")
          expect(dbl.bar { nil }).to eq(42)
        end
      end

      it "supports blocks and has non-union return types" do
        aggregate_failures do
          expect(dbl.foo { nil }).to compile_as(String)
          expect(dbl.bar { nil }).to compile_as(Int32)
        end
      end

      it "fails on undefined messages" do
        expect do
          dbl.baz { nil }
        end.to raise_error(Spectator::UnexpectedMessage, /baz/)
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

    context "mixing keyword arguments" do
      double(:test6, foo: "kwargs", bar: 42) do
        stub def foo
          "block"
        end

        stub def baz
          "block"
        end

        stub def baz(value)
          "block2"
        end
      end

      subject(dbl) { double(:test6) }

      it "overrides the keyword arguments with the block methods" do
        expect(dbl.foo).to eq("block")
      end

      it "falls back to the keyword argument value for mismatched arguments" do
        expect(dbl.foo(42)).to eq("kwargs")
      end

      it "can call methods defined only by keyword arguments" do
        expect(dbl.bar).to eq(42)
      end

      it "can call methods defined only by the block" do
        expect(dbl.baz).to eq("block")
      end

      it "can call methods defined by the block with different signatures" do
        expect(dbl.baz(42)).to eq("block2")
      end
    end

    context "methods accepting blocks" do
      double(:test7) do
        stub def foo(&)
          yield
        end

        stub def bar(& : Int32 -> String)
          yield 42
        end
      end

      subject(dbl) { double(:test7) }

      it "defines the method and yields" do
        expect(dbl.foo { :xyz }).to eq(:xyz)
      end

      it "matches methods with block argument type restrictions" do
        expect(dbl.bar &.to_s).to eq("42")
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

  describe "predefined method stubs" do
    double(:test8, foo: 42)

    let(dbl) { double(:test8, foo: 7) }

    it "overrides the original value" do
      expect(dbl.foo).to eq(7)
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

  describe "context" do
    double(:context_double, predefined: :predefined, override: :predefined) do
      stub abstract def memoize : Symbol

      stub def inline : Symbol
        :inline # Memoized values can't be used here.
      end

      stub def reference : String
        memoize.to_s
      end
    end

    let(memoize) { :memoize }
    let(override) { :override }
    let(dbl) { double(:context_double, override: override) }

    before { allow(dbl).to receive(:memoize).and_return(memoize) }

    it "doesn't change predefined values" do
      expect(dbl.predefined).to eq(:predefined)
    end

    it "can use memoized values for overrides" do
      expect(dbl.override).to eq(:override)
    end

    it "can use memoized values for stubs" do
      expect(dbl.memoize).to eq(:memoize)
    end

    it "can override inline stubs" do
      expect { allow(dbl).to receive(:inline).and_return(override) }.to change { dbl.inline }.from(:inline).to(:override)
    end

    it "can reference memoized values with indirection" do
      expect { allow(dbl).to receive(:memoize).and_return(override) }.to change { dbl.reference }.from("memoize").to("override")
    end
  end

  describe "class doubles" do
    double(:class_double) do
      abstract_stub def self.abstract_method
        :abstract
      end

      stub def self.default_method
        :default
      end

      stub def self.args(arg)
        arg
      end

      stub def self.method1
        :method1
      end

      stub def self.reference
        method1.to_s
      end
    end

    let(dbl) { class_double(:class_double) }

    it "raises on abstract stubs" do
      expect { dbl.abstract_method }.to raise_error(Spectator::UnexpectedMessage, /abstract_method/)
    end

    it "can define default stubs" do
      expect(dbl.default_method).to eq(:default)
    end

    it "can define new stubs" do
      expect { allow(dbl).to receive(:args).and_return(42) }.to change { dbl.args(5) }.from(5).to(42)
    end

    it "can override class method stubs" do
      allow(dbl).to receive(:method1).and_return(:override)
      expect(dbl.method1).to eq(:override)
    end

    it "can reference stubs" do
      allow(dbl).to receive(:method1).and_return(:reference)
      expect(dbl.reference).to eq("reference")
    end
  end
end
