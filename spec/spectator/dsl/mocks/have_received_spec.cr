require "../../../spec_helper"

Spectator.describe "Stubbable receiver DSL" do
  context "with a double" do
    double(:dbl, foo: 42)

    let(dbl) { double(:dbl) }

    # Ensure invocations don't leak between examples.
    pre_condition { expect(dbl).to_not have_received(:foo), "Leaked method calls from previous examples" }

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

  context "with a class double" do
    double(:dbl) do
      stub def self.foo
        42
      end

      stub def self.foo(arg)
        42
      end
    end

    let(dbl) { class_double(:dbl) }

    # Ensure invocations don't leak between examples.
    pre_condition { expect(dbl).to_not have_received(:foo), "Leaked method calls from previous examples" }

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

    # Ensure invocations don't leak between examples.
    pre_condition { expect(fake).to_not have_received(:foo), "Leaked method calls from previous examples" }

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

  context "with a class mock" do
    class MyClass
      def self.foo(arg) : Int32
        42
      end
    end

    mock(MyClass)

    let(fake) { class_mock(MyClass) }

    # Ensure invocations don't leak between examples.
    pre_condition { expect(fake).to_not have_received(:foo), "Leaked method calls from previous examples" }

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
