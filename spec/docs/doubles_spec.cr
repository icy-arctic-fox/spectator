require "../spec_helper"

# https://gitlab.com/arctic-fox/spectator/-/wikis/Doubles
Spectator.describe "Doubles Docs" do
  let(answer) { 42 }

  double :my_double, answer: 5 do
    def answer(arg1, arg2)
      arg1 + arg2
    end
  end

  it "does something" do
    dbl = double(:my_double, answer: answer)
    expect(dbl.answer).to eq(42)
    expect(dbl.answer(1, 2)).to eq(3)
  end

  class Emitter
    def initialize(@value : Int32)
    end

    def emit(target)
      target.call(@value)
    end
  end

  context "Expecting Behavior" do
    describe Emitter do
      subject { Emitter.new(42) }

      double :target, call: nil

      describe "#emit" do
        it "invokes #call on the target" do
          target = double(:target)
          subject.emit(target)
          expect(target).to have_received(:call).with(42)
        end
      end
    end

    it "does something" do
      dbl = double(:my_double)
      allow(dbl).to receive(:answer).and_return(42) # Merge this line...
      dbl.answer
      expect(dbl).to have_received(:answer) # and this line.
    end

    it "does something" do
      dbl = double(:my_double)
      expect(dbl).to receive(:answer).and_return(42)
      dbl.answer
    end
  end

  context "Class Doubles" do
    double :my_double do
      # Define class methods with `self.` prefix.
      stub def self.something
        42
      end
    end

    it "does something" do
      # Default stubs can be defined with key-value pairs (keyword arguments).
      dbl = class_double(:my_double, something: 3)
      expect(dbl.something).to eq(3)

      # Stubs can be changed with `allow`.
      allow(dbl).to receive(:something).and_return(5)
      expect(dbl.something).to eq(5)

      # Even the expect-receive syntax works.
      expect(dbl).to receive(:something).and_return(7)
      dbl.something
    end
  end
end
