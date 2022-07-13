require "../spec_helper"

abstract class SdkInterface
  abstract def register_hook(name, &block)
end

class Example
  def initialize(@sdk : Sdk)
  end

  def configure
    @sdk.register_hook("name") do
      nil
    end
  end
end

class Sdk < SdkInterface
  def initialize
  end

  def register_hook(name, &block)
    nil
  end
end

Spectator.describe Example do
  mock Sdk

  describe "#configure" do
    it "registers a block on configure" do
      sdk = mock(Sdk)
      example_class = Example.new(sdk)
      allow(sdk).to receive(register_hook())

      example_class.configure

      expect(sdk).to have_received(register_hook()).with("name")
    end
  end
end
