require "../../../spec_helper"

Spectator.describe "Stubbable receiver DSL" do
  context "with a double" do
    double(:dbl, foo: 42)

    let(dbl) { double(:dbl) }

    it "matches when a message is received" do
      dbl.foo
      expect(dbl).to have_received(:foo)
    end

    it "matches when a message isn't received" do
      expect(dbl).to_not have_received(:foo)
    end

    it "matches when a message is received with matching arguments" do
      dbl.foo(:bar)
      expect(dbl).to have_received(:foo).with(:bar)
    end

    it "matches when a message without arguments is received" do
      dbl.foo
      expect(dbl).to_not have_received(:foo).with(:bar)
    end

    it "matches when a message without arguments isn't received" do
      expect(dbl).to_not have_received(:foo).with(:bar)
    end

    it "matches when a message with arguments isn't received" do
      dbl.foo(:bar)
      expect(dbl).to_not have_received(:foo).with(:baz)
    end
  end

  context "with a mock" do
    abstract class MyClass
      abstract def foo(arg) : Int32
    end

    mock(MyClass, foo: 42)

    let(fake) { mock(MyClass) }

    it "matches when a message is received" do
      fake.foo(:bar)
      expect(fake).to have_received(:foo)
    end

    it "matches when a message isn't received" do
      expect(fake).to_not have_received(:foo)
    end

    it "matches when a message is received with matching arguments" do
      fake.foo(:bar)
      expect(fake).to have_received(:foo).with(:bar)
    end

    it "matches when a message without arguments is received" do
      expect(fake).to_not have_received(:foo).with(:bar)
    end

    it "matches when a message with arguments isn't received" do
      fake.foo(:bar)
      expect(fake).to_not have_received(:foo).with(:baz)
    end
  end
end
