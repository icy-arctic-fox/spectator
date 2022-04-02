require "../../spec_helper"

Spectator.describe Spectator::Allow do
  let(dbl) { Spectator::LazyDouble.new(foo: 42) }
  let(stub) { Spectator::ValueStub.new(:foo, 123) }
  subject(alw) { Spectator::Allow.new(dbl) }

  describe "#to" do
    it "applies a stub" do
      expect { alw.to(stub) }.to change { dbl.foo }.from(42).to(123)
    end
  end
end
