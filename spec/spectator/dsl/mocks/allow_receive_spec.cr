require "../../../spec_helper"

Spectator.describe "Allow stub DSL" do
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
    end

    it "matches when a message is received" do
      allow(dbl).to receive(:foo)
      expect { dbl.foo }.to_not raise_error
    end

    it "returns the correct value" do
      allow(dbl).to receive(:value).and_return(42)
      expect(dbl.value).to eq(42)
    end

    it "matches when a message is received with matching arguments" do
      allow(dbl).to receive(:foo).with(:bar)
      expect { dbl.foo(:bar) }.to_not raise_error
    end

    it "raises when a message without arguments is received" do
      allow(dbl).to receive(:foo).with(:bar)
      expect { dbl.foo }.to raise_error(Spectator::UnexpectedMessage, /foo/)
    end

    it "raises when a message with different arguments is received" do
      allow(dbl).to receive(:foo).with(:baz)
      expect { dbl.foo(:bar) }.to raise_error(Spectator::UnexpectedMessage, /foo/)
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
    end

    it "matches when a message is received" do
      allow(dbl).to receive(:foo)
      expect { dbl.foo }.to_not raise_error
    end

    it "returns the correct value" do
      allow(dbl).to receive(:value).and_return(42)
      expect(dbl.value).to eq(42)
    end

    it "matches when a message is received with matching arguments" do
      allow(dbl).to receive(:foo).with(:bar)
      expect { dbl.foo(:bar) }.to_not raise_error
    end

    it "raises when a message without arguments is received" do
      allow(dbl).to receive(:foo).with(:bar)
      expect { dbl.foo }.to raise_error(Spectator::UnexpectedMessage, /foo/)
    end

    it "raises when a message with different arguments is received" do
      allow(dbl).to receive(:foo).with(:baz)
      expect { dbl.foo(:bar) }.to raise_error(Spectator::UnexpectedMessage, /foo/)
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
    end

    it "matches when a message is received" do
      allow(fake).to receive(:foo).and_return(42)
      expect(fake.foo).to eq(42)
    end

    it "returns the correct value" do
      allow(fake).to receive(:foo).and_return(42)
      expect(fake.foo).to eq(42)
    end

    it "matches when a message is received with matching arguments" do
      allow(fake).to receive(:foo).with(:bar).and_return(42)
      expect(fake.foo(:bar)).to eq(42)
    end

    it "raises when a message without arguments is received" do
      allow(fake).to receive(:foo).with(:bar)
      expect { fake.foo }.to raise_error(Spectator::UnexpectedMessage, /foo/)
    end

    it "raises when a message with different arguments is received" do
      allow(fake).to receive(:foo).with(:baz)
      expect { fake.foo(:bar) }.to raise_error(Spectator::UnexpectedMessage, /foo/)
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
    pre_condition { expect(fake.foo).to eq(42) }

    it "matches when a message is received" do
      allow(fake).to receive(:foo).and_return(0)
      expect(fake.foo).to eq(0)
    end

    it "returns the correct value" do
      allow(fake).to receive(:foo).and_return(0)
      expect(fake.foo).to eq(0)
    end

    it "matches when a message is received with matching arguments" do
      allow(fake).to receive(:foo).with(:bar).and_return(0)
      expect(fake.foo(:bar)).to eq(0)
    end

    it "calls the original when a message without arguments is received" do
      allow(fake).to receive(:foo).with(:bar)
      expect(fake.foo).to eq(42)
    end

    it "calls the original when a message with different arguments is received" do
      allow(fake).to receive(:foo).with(:baz)
      expect(fake.foo(:bar)).to eq(42)
    end
  end
end
