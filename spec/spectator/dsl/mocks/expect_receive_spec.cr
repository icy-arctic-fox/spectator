require "../../../spec_helper"

Spectator.describe "Deferred stub expectation DSL" do
  context "with a double" do
    double(:dbl) do
      # Ensure the original is never called.
      stub abstract def foo : Nil
      stub abstract def foo(arg) : Nil
    end

    let(dbl) { double(:dbl) }

    it "matches when a message is received" do
      expect(dbl).to receive(:foo)
      dbl.foo
    end

    it "matches when a message isn't received" do
      expect(dbl).to_not receive(:foo)
    end

    it "matches when a message is received with matching arguments" do
      expect(dbl).to receive(:foo).with(:bar)
      dbl.foo(:bar)
    end

    it "matches when a message without arguments is received" do
      expect(dbl).to_not receive(:foo).with(:bar)
      dbl.foo
    end

    it "matches when a message without arguments isn't received" do
      expect(dbl).to_not receive(:foo).with(:bar)
    end

    it "matches when a message with arguments isn't received" do
      expect(dbl).to_not receive(:foo).with(:baz)
      dbl.foo(:bar)
    end
  end

  context "with a mock" do
    abstract class MyClass
      abstract def foo : Int32
      abstract def foo(arg) : Int32
    end

    mock(MyClass)

    let(fake) { mock(MyClass) }

    it "matches when a message is received" do
      expect(fake).to receive(:foo).and_return(42)
      fake.foo(:bar)
    end

    it "matches when a message isn't received" do
      expect(fake).to_not receive(:foo)
    end

    it "matches when a message is received with matching arguments" do
      expect(fake).to receive(:foo).with(:bar).and_return(42)
      fake.foo(:bar)
    end

    it "matches when a message without arguments is received" do
      expect(fake).to_not receive(:foo).with(:bar)
      fake.foo
    end

    it "matches when a message without arguments is received" do
      expect(fake).to_not receive(:foo).with(:bar)
    end

    it "matches when a message with arguments isn't received" do
      expect(fake).to_not receive(:foo).with(:baz).and_return(42)
      fake.foo(:bar)
    end
  end
end
