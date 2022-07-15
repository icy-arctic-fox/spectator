require "../spec_helper"

# https://gitlab.com/arctic-fox/spectator/-/wikis/Stubs
Spectator.describe "Stubs Docs" do
  double :time_double, time_in: Time.utc(2016, 2, 15, 10, 20, 30)
  double :my_double, something: 42, answer?: false

  let(dbl) { double(:my_double) }

  def receive_time_in_utc
    receive(:time_in).with(:utc).and_return(Time.utc)
  end

  it "returns the time in UTC" do
    dbl = double(:time_double)
    allow(dbl).to receive_time_in_utc
    expect(dbl.time_in(:utc).zone.name).to eq("UTC")
  end

  context "Modifiers" do
    double :my_double, something: 42, answer?: false

    let(dbl) { double(:my_double) }

    context "and_return" do
      specify do
        allow(dbl).to receive(:something).and_return(42)
        expect(dbl.something).to eq(42)
      end

      specify do
        allow(dbl).to receive(:something).and_return(1, 2, 3)
        expect(dbl.something).to eq(1)
        expect(dbl.something).to eq(2)
        expect(dbl.something).to eq(3)
        expect(dbl.something).to eq(3)
      end
    end

    context "and_raise" do
      specify do
        allow(dbl).to receive(:something).and_raise # Raise `Exception` with no message.
        expect { dbl.something }.to raise_error(Exception)

        allow(dbl).to receive(:something).and_raise(IO::Error) # Raise `IO::Error` with no message.
        expect { dbl.something }.to raise_error(IO::Error)

        allow(dbl).to receive(:something).and_raise(KeyError, "Missing key: :foo") # Raise `KeyError` with the specified message.
        expect { dbl.something }.to raise_error(KeyError, "Missing key: :foo")

        exception = ArgumentError.new("Malformed")
        allow(dbl).to receive(:something).and_raise(exception) # Raise `exception`.
        expect { dbl.something }.to raise_error(ArgumentError, "Malformed")
      end
    end

    context "with" do
      specify do
        allow(dbl).to receive(:answer?).and_return(false)
        allow(dbl).to receive(:answer?).with(42).and_return(true)
        expect(dbl.answer?(42)).to be_true
        expect(dbl.answer?(5)).to be_false
      end

      specify do
        allow(dbl).to receive(:answer?).with(Int, key: /foo/).and_return(true)
        expect(dbl.answer?(42, key: "foobar")).to be_true
      end
    end
  end

  context "Expect-Receive Syntax" do
    class Driver
      def doit(thing)
        thing.call
      end
    end

    describe Driver do
      describe "#doit" do
        double :thing, call: 5

        it "calls thing.call (1)" do
          thing = double(:thing)
          allow(thing).to receive(:call).and_return(42)
          subject.doit(thing)
          expect(thing).to have_received(:call)
        end

        it "calls thing.call (2)" do
          thing = double(:thing)
          expect(thing).to receive(:call).and_return(42)
          subject.doit(thing)
        end

        it "calls thing.call (3)" do
          thing = double(:thing)
          allow(thing).to receive(:call).and_return(42)
          expect(thing).to_eventually have_received(:call)
          subject.doit(thing)
        end
      end
    end

    specify do
      expect(dbl).to receive(:answer?).with(42).and_return(true)
      dbl.answer?(42)
    end
  end

  context "Default Stubs" do
    double :my_double, foo: "foo" do # Default stub for #foo
      # Default stub for #bar
      stub def bar
        "bar"
      end
    end

    it "does something" do
      dbl = double(:my_double)
      expect(dbl.foo).to eq("foo")
      expect(dbl.bar).to eq("bar")

      # Overriding initial defaults.
      dbl = double(:my_double, foo: "FOO", bar: "BAR")
      expect(dbl.foo).to eq("FOO")
      expect(dbl.bar).to eq("BAR")
    end
  end
end
