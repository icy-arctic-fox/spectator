require "../../spec_helper"

Spectator.describe Spectator::MethodCall do
  let(arguments) { Spectator::Arguments.capture(42, "foobar", foo: :bar) }
  subject(call) { Spectator::MethodCall.new(:foo, arguments) }

  it "stores the method name" do
    expect(&.method).to eq(:foo)
  end

  it "stores arguments" do
    expect(&.arguments).to eq(arguments)
  end

  describe ".capture" do
    subject(call) { Spectator::MethodCall.capture(:foo, 42, "foobar", foo: :bar) }

    it "stores the method name" do
      expect(&.method).to eq(:foo)
    end

    it "stores arguments" do
      expect(&.arguments).to eq(arguments)
    end
  end
end
