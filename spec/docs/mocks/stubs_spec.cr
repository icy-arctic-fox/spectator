require "../../spec_helper"

Spectator.describe "Stubs" do
  context "Implementing a Stub" do
    double :my_double do
      stub answer : Int32
      stub do_something
    end

    it "knows the answer" do
      dbl = double(:my_double)
      allow(dbl).to receive(:answer).and_return(42)
      expect(dbl.answer).to eq(42)
    end

    it "does something" do
      dbl = double(:my_double)
      allow(dbl).to receive(:do_something)
      expect(dbl.do_something).to be_nil
    end

    context "and_return" do
      double :my_double do
        stub to_s : String
        stub do_something
      end

      it "stringifies" do
        dbl = double(:my_double)
        allow(dbl).to receive(:to_s).and_return("foobar")
        expect(dbl.to_s).to eq("foobar")
      end

      it "returns gibberish" do
        dbl = double(:my_double)
        allow(dbl).to receive(:to_s).and_return("foo", "bar", "baz")
        expect(dbl.to_s).to eq("foo")
        expect(dbl.to_s).to eq("bar")
        expect(dbl.to_s).to eq("baz")
        expect(dbl.to_s).to eq("baz")
      end

      it "returns nil" do
        dbl = double(:my_double)
        allow(dbl).to receive(:do_something).and_return
        expect(dbl.do_something).to be_nil
      end
    end

    context "and_raise" do
      double :my_double do
        stub oops
      end

      it "raises an error" do
        dbl = double(:my_double)
        allow(dbl).to receive(:oops).and_raise(DivisionByZeroError.new)
        expect { dbl.oops }.to raise_error(DivisionByZeroError)
      end
      it "raises an error" do
        dbl = double(:my_double)
        allow(dbl).to receive(:oops).and_raise("Something broke")
        expect { dbl.oops }.to raise_error(/Something broke/)
      end
      it "raises an error" do
        dbl = double(:my_double)
        allow(dbl).to receive(:oops).and_raise(ArgumentError, "Size must be > 0")
        expect { dbl.oops }.to raise_error(ArgumentError, /Size/)
      end
    end

    context "and_call_original" do
      class MyType
        def foo
          "foo"
        end
      end

      mock MyType do
        stub foo
      end

      it "calls the original" do
        instance = MyType.new
        allow(instance).to receive(:foo).and_call_original
        expect(instance.foo).to eq("foo")
      end
    end

    context "Short-hand for Multiple Stubs" do
      double :my_double do
        stub method_a : Symbol
        stub method_b : Int32
        stub method_c : String
      end

      it "does something" do
        dbl = double(:my_double)
        allow(dbl).to receive_messages(method_a: :foo, method_b: 42, method_c: "foobar")
        expect(dbl.method_a).to eq(:foo)
        expect(dbl.method_b).to eq(42)
        expect(dbl.method_c).to eq("foobar")
      end
    end

    context "Custom Implementation" do
      double :my_double do
        stub foo : String
      end

      it "does something" do
        dbl = double(:my_double)
        allow(dbl).to receive(:foo) { "foo" }
        expect(dbl.foo).to eq("foo")
      end
    end

    context "Arguments" do
      double :my_double do
        stub add(a, b) { a + b }
        stub do_something(arg) { arg } # Return the argument by default.
      end

      it "adds two numbers" do
        dbl = double(:my_double)
        allow(dbl).to receive(:add).and_return(7)
        expect(dbl.add(1, 2)).to eq(7)
      end

      it "does basic matching" do
        dbl = double(:my_double)
        allow(dbl).to receive(:do_something).with(1).and_return(42)
        allow(dbl).to receive(:do_something).with(2).and_return(22)
        expect(dbl.do_something(1)).to eq(42)
        expect(dbl.do_something(2)).to eq(22)
      end

      it "can call the original" do
        dbl = double(:my_double)
        allow(dbl).to receive(:do_something).with(1).and_return(42)
        allow(dbl).to receive(:do_something).with(2).and_call_original
        expect(dbl.do_something(1)).to eq(42)
        expect(dbl.do_something(2)).to eq(2)
      end

      it "falls back to the default" do
        dbl = double(:my_double)
        allow(dbl).to receive(:do_something).and_return(22)
        allow(dbl).to receive(:do_something).with(1).and_return(42)
        expect(dbl.do_something(1)).to eq(42)
        expect(dbl.do_something(2)).to eq(22)
        expect(dbl.do_something(3)).to eq(22)
      end

      it "does advanced matching" do
        dbl = double(:my_double)
        allow(dbl).to receive(:do_something).with(Int32).and_return(42)
        allow(dbl).to receive(:do_something).with(String).and_return("foobar")
        allow(dbl).to receive(:do_something).with(/hi/).and_return("hello there")
        expect(dbl.do_something(1)).to eq(42)
        expect(dbl.do_something("foo")).to eq("foobar")
        expect(dbl.do_something("hi there")).to eq("hello there")
      end
    end
  end
end
