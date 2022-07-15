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

  context "count modifiers" do
    double(:dbl, foo: 42)

    let(dbl) { double(:dbl) }

    describe "#once" do
      it "matches when the stub is called once" do
        dbl.foo
        expect(dbl).to have_received(:foo).once
      end

      it "doesn't match when the stub isn't called" do
        expect(dbl).to_not have_received(:foo).once
      end

      it "doesn't match when the stub is called twice" do
        2.times { dbl.foo }
        expect(dbl).to_not have_received(:foo).once
      end
    end

    describe "#twice" do
      it "matches when the stub is called twice" do
        2.times { dbl.foo }
        expect(dbl).to have_received(:foo).twice
      end

      it "doesn't match when the stub isn't called" do
        expect(dbl).to_not have_received(:foo).twice
      end

      it "doesn't match when the stub is called once" do
        dbl.foo
        expect(dbl).to_not have_received(:foo).twice
      end

      it "doesn't match when the stub is called thrice" do
        3.times { dbl.foo }
        expect(dbl).to_not have_received(:foo).twice
      end
    end

    describe "#exactly" do
      it "matches when the stub is called the exact amount" do
        3.times { dbl.foo }
        expect(dbl).to have_received(:foo).exactly(3).times
      end

      it "doesn't match when the stub isn't called" do
        expect(dbl).to_not have_received(:foo).exactly(3).times
      end

      it "doesn't match when the stub is called less than the amount" do
        2.times { dbl.foo }
        expect(dbl).to_not have_received(:foo).exactly(3).times
      end

      it "doesn't match when the stub is called more than the amount" do
        4.times { dbl.foo }
        expect(dbl).to_not have_received(:foo).exactly(3).times
      end
    end

    describe "#at_least" do
      it "matches when the stub is called the exact amount" do
        3.times { dbl.foo }
        expect(dbl).to have_received(:foo).at_least(3).times
      end

      it "doesn't match when the stub isn't called" do
        expect(dbl).to_not have_received(:foo).at_least(3).times
      end

      it "doesn't match when the stub is called less than the amount" do
        2.times { dbl.foo }
        expect(dbl).to_not have_received(:foo).at_least(3).times
      end

      it "matches when the stub is called more than the amount" do
        4.times { dbl.foo }
        expect(dbl).to have_received(:foo).at_least(3).times
      end
    end

    describe "#at_most" do
      it "matches when the stub is called the exact amount" do
        3.times { dbl.foo }
        expect(dbl).to have_received(:foo).at_most(3).times
      end

      it "matches when the stub isn't called" do
        expect(dbl).to have_received(:foo).at_most(3).times
      end

      it "matches when the stub is called less than the amount" do
        2.times { dbl.foo }
        expect(dbl).to have_received(:foo).at_most(3).times
      end

      it "doesn't match when the stub is called more than the amount" do
        4.times { dbl.foo }
        expect(dbl).to_not have_received(:foo).at_most(3).times
      end
    end

    describe "#at_least_once" do
      it "matches when the stub is called once" do
        dbl.foo
        expect(dbl).to have_received(:foo).at_least_once
      end

      it "doesn't match when the stub isn't called" do
        expect(dbl).to_not have_received(:foo).at_least_once
      end

      it "matches when the stub is called more than once" do
        2.times { dbl.foo }
        expect(dbl).to have_received(:foo).at_least_once
      end
    end

    describe "#at_least_twice" do
      it "doesn't match when the stub is called once" do
        dbl.foo
        expect(dbl).to_not have_received(:foo).at_least_twice
      end

      it "doesn't match when the stub isn't called" do
        expect(dbl).to_not have_received(:foo).at_least_twice
      end

      it "matches when the stub is called twice" do
        2.times { dbl.foo }
        expect(dbl).to have_received(:foo).at_least_twice
      end

      it "matches when the stub is called more than twice" do
        3.times { dbl.foo }
        expect(dbl).to have_received(:foo).at_least_twice
      end
    end

    describe "#at_most_once" do
      it "matches when the stub is called once" do
        dbl.foo
        expect(dbl).to have_received(:foo).at_most_once
      end

      it "matches when the stub isn't called" do
        expect(dbl).to have_received(:foo).at_most_once
      end

      it "doesn't match when the stub is called more than once" do
        2.times { dbl.foo }
        expect(dbl).to_not have_received(:foo).at_most_once
      end
    end

    describe "#at_most_twice" do
      it "matches when the stub is called once" do
        dbl.foo
        expect(dbl).to have_received(:foo).at_most_twice
      end

      it "matches when the stub isn't called" do
        expect(dbl).to have_received(:foo).at_most_twice
      end

      it "matches when the stub is called twice" do
        2.times { dbl.foo }
        expect(dbl).to have_received(:foo).at_most_twice
      end

      it "doesn't match when the stub is called more than twice" do
        3.times { dbl.foo }
        expect(dbl).to_not have_received(:foo).at_most_twice
      end
    end
  end
end
