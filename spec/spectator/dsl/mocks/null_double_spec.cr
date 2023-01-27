require "../../../spec_helper"

Spectator.describe "Null double DSL" do
  context "specifying methods as keyword args" do
    double(:test, foo: "foobar", bar: 42)
    subject(dbl) { double(:test).as_null_object }

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

    it "returns self for unexpected messages" do
      expect(dbl.baz).to be(dbl)
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

      it "returns self on undefined messages" do
        expect(dbl.baz { nil }).to be(dbl)
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

      subject(dbl) { double(:test2).as_null_object }

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

      subject(dbl) { double(:test3).as_null_object }

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

      subject(dbl) { double(:test4).as_null_object }

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

      subject(dbl) { double(:test5).as_null_object }

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

      subject(dbl) { double(:test6).as_null_object }

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

      subject(dbl) { double(:test7).as_null_object }

      it "defines the method and yields" do
        expect(dbl.foo { :xyz }).to eq(:xyz)
      end

      it "matches methods with block argument type restrictions" do
        expect(dbl.bar &.to_s).to eq("42")
      end
    end
  end

  describe "predefined method stubs" do
    double(:test8, foo: 42)

    let(dbl) { double(:test8, foo: 7).as_null_object }

    it "overrides the original value" do
      expect(dbl.foo).to eq(7)
    end
  end
end
