require "../../../spec_helper"

Spectator.describe "Deferred stub expectation DSL" do
  context "with a double" do
    double(:dbl) do
      # Ensure the original is never called.
      stub abstract def foo : Nil
      stub abstract def foo(arg) : Nil
      stub abstract def value : Int32
    end

    let(dbl) { double(:dbl) }

    # Ensure invocations don't leak between examples.
    pre_condition { expect(dbl).to_not have_received(:foo), "Leaked method calls from previous examples" }

    # Ensure stubs don't leak between examples.
    pre_condition do
      expect { dbl.foo }.to raise_error(Spectator::UnexpectedMessage)
      dbl._spectator_clear_calls # Don't include previous call in results.
    end

    it "matches when a message is received" do
      expect(dbl).to receive(:foo)
      dbl.foo
    end

    it "returns the correct value" do
      expect(dbl).to receive(:value).and_return(42)
      expect(dbl.value).to eq(42)
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

  context "with a class double" do
    double(:dbl) do
      # Ensure the original is never called.
      abstract_stub def self.foo : Nil
      end

      abstract_stub def self.foo(arg) : Nil
      end

      abstract_stub def self.value : Int32
        42
      end
    end

    let(dbl) { class_double(:dbl) }

    # Ensure invocations don't leak between examples.
    pre_condition { expect(dbl).to_not have_received(:foo), "Leaked method calls from previous examples" }

    # Ensure stubs don't leak between examples.
    pre_condition do
      expect { dbl.foo }.to raise_error(Spectator::UnexpectedMessage)
      dbl._spectator_clear_calls # Don't include previous call in results.
    end

    it "matches when a message is received" do
      expect(dbl).to receive(:foo)
      dbl.foo
    end

    it "returns the correct value" do
      expect(dbl).to receive(:value).and_return(42)
      expect(dbl.value).to eq(42)
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

    # Ensure invocations don't leak between examples.
    pre_condition { expect(fake).to_not have_received(:foo), "Leaked method calls from previous examples" }

    # Ensure stubs don't leak between examples.
    pre_condition do
      expect { fake.foo }.to raise_error(Spectator::UnexpectedMessage)
      fake._spectator_clear_calls # Don't include previous call in results.
    end

    it "matches when a message is received" do
      expect(fake).to receive(:foo).and_return(42)
      fake.foo(:bar)
    end

    it "returns the correct value" do
      expect(fake).to receive(:foo).and_return(42)
      expect(fake.foo).to eq(42)
    end

    it "matches when a message isn't received" do
      expect(fake).to_not receive(:foo)
    end

    it "matches when a message is received with matching arguments" do
      expect(fake).to receive(:foo).with(:bar).and_return(42)
      fake.foo(:bar)
    end

    it "matches when a message without arguments is received" do
      expect(fake).to_not receive(:foo).with(:bar).and_return(42)
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

  context "with a class mock" do
    class MyClass
      def self.foo : Int32
        42
      end

      def self.foo(arg) : Int32
        42
      end
    end

    mock(MyClass)

    let(fake) { class_mock(MyClass) }

    # Ensure invocations don't leak between examples.
    pre_condition { expect(fake).to_not have_received(:foo), "Leaked method calls from previous examples" }

    # Ensure stubs don't leak between examples.
    pre_condition do
      expect(fake.foo).to eq(42)
      fake._spectator_clear_calls # Don't include previous call in results.
    end

    it "matches when a message is received" do
      expect(fake).to receive(:foo).and_return(0)
      fake.foo(:bar)
    end

    it "returns the correct value" do
      expect(fake).to receive(:foo).and_return(0)
      expect(fake.foo).to eq(0)
    end

    it "matches when a message isn't received" do
      expect(fake).to_not receive(:foo)
    end

    it "matches when a message is received with matching arguments" do
      expect(fake).to receive(:foo).with(:bar).and_return(0)
      fake.foo(:bar)
    end

    it "matches when a message without arguments is received" do
      expect(fake).to_not receive(:foo).with(:bar).and_return(0)
      fake.foo
    end

    it "matches when a message without arguments is received" do
      expect(fake).to_not receive(:foo).with(:bar)
    end

    it "matches when a message with arguments isn't received" do
      expect(fake).to_not receive(:foo).with(:baz).and_return(0)
      fake.foo(:bar)
    end
  end
end
