require "../../spec_helper"

Spectator.describe Spectator::Allow do
  let(dbl) { Spectator::LazyDouble.new(foo: 42) }
  let(stub) { Spectator::ValueStub.new(:foo, 123) }
  subject(alw) { Spectator::Allow.new(dbl) }

  describe "#to" do
    it "applies a stub" do
      expect { alw.to(stub) }.to change { dbl.foo }.from(42).to(123)
    end

    context "leak" do
      class Thing
        def foo
          42
        end
      end

      mock Thing

      getter(thing : Thing) { mock(Thing) }

      # Workaround type restrictions requiring a constant.
      def fake
        class_mock(Thing).cast(thing)
      end

      specify do
        expect { allow(fake).to(stub) }.to change { fake.foo }.from(42).to(123)
      end

      # This example must be run after the previous (random order may break this).
      it "clears the stub after the example completes" do
        expect { fake.foo }.to eq(42)
      end
    end
  end
end
