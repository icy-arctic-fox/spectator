require "../../spec_helper"

Spectator.describe Spectator::LazyDouble do
  context "plain double" do
    subject(dbl) { Spectator::LazyDouble.new("dbl-name", foo: 42, bar: "baz") }

    it "responds to defined messages" do
      aggregate_failures do
        expect(dbl.foo).to eq(42)
        expect(dbl.bar).to eq("baz")
      end
    end

    it "fails on undefined messages" do
      expect { dbl.baz }.to raise_error(Spectator::UnexpectedMessage, /baz/)
    end

    it "reports the name in errors" do
      expect { dbl.baz }.to raise_error(/"dbl-name"/)
    end

    it "reports arguments" do
      expect { dbl.baz(123, "qux", field: :value) }.to raise_error(Spectator::UnexpectedMessage, /\(123, "qux", field: :value\)/)
    end

    context "blocks" do
      it "supports blocks" do
        aggregate_failures do
          expect(dbl.foo { nil }).to eq(42)
          expect(dbl.bar { nil }).to eq("baz")
        end
      end

      it "fails on undefined messages" do
        expect do
          dbl.baz { nil }
        end.to raise_error(Spectator::UnexpectedMessage, /baz/)
      end
    end
  end

  context "without a double name" do
    subject(dbl) { Spectator::LazyDouble.new }

    it "reports as anonymous" do
      expect { dbl.baz }.to raise_error(/anonymous/i)
    end
  end

  context "with nillable values" do
    subject(dbl) { Spectator::LazyDouble.new(foo: nil.as(String?), bar: nil) }

    it "doesn't raise on nil" do
      aggregate_failures do
        expect(dbl.foo).to be_nil
        expect(dbl.bar).to be_nil
      end
    end
  end

  context "with common object methods" do
    let(dup) { double(:dup) }

    subject(dbl) do
      Spectator::LazyDouble.new(nil, [
        Spectator::ValueStub.new(:"!=", false),
        Spectator::ValueStub.new(:"!~", false),
        Spectator::ValueStub.new(:"==", true),
        Spectator::ValueStub.new(:"===", true),
        Spectator::ValueStub.new(:"=~", nil),
        Spectator::ValueStub.new(:dup, dup),
        Spectator::ValueStub.new(:hash, 42_u64),
        Spectator::ValueStub.new(:"in?", true),
        Spectator::ValueStub.new(:inspect, "inspect"),
        Spectator::ValueStub.new(:itself, dup),
        Spectator::ValueStub.new(:"not_nil!", dup),
        Spectator::ValueStub.new(:pretty_inspect, "pretty_inspect"),
        Spectator::ValueStub.new(:tap, dup),
        Spectator::ValueStub.new(:to_json, "to_json"),
        Spectator::ValueStub.new(:to_pretty_json, "to_pretty_json"),
        Spectator::ValueStub.new(:to_s, "to_s"),
        Spectator::ValueStub.new(:to_yaml, "to_yaml"),
        Spectator::ValueStub.new(:try, nil),
        Spectator::ValueStub.new(:object_id, 42_u64),
        Spectator::ValueStub.new(:"same?", true),
      ] of Spectator::Stub)
    end

    it "responds with defined messages" do
      aggregate_failures do
        expect(dbl.!=(42)).to eq(false)
        expect(dbl.!~(42)).to eq(false)
        expect(dbl.==(42)).to eq(true)
        expect(dbl.===(42)).to eq(true)
        expect(dbl.=~(42)).to be_nil
        expect(dbl.dup).to be(dup)
        expect(dbl.hash).to eq(42_u64)
        expect(dbl.in?([42])).to eq(true)
        expect(dbl.in?(1, 2, 3)).to eq(true)
        expect(dbl.inspect).to eq("inspect")
        expect(dbl.itself).to be(dup)
        expect(dbl.not_nil!).to be(dup)
        expect(dbl.pretty_inspect).to eq("pretty_inspect")
        expect(dbl.tap { nil }).to be(dup)
        expect(dbl.to_json).to eq("to_json")
        expect(dbl.to_pretty_json).to eq("to_pretty_json")
        expect(dbl.to_s).to eq("to_s")
        expect(dbl.to_yaml).to eq("to_yaml")
        expect(dbl.try { nil }).to be_nil
        expect(dbl.object_id).to eq(42_u64)
        expect(dbl.same?(dbl)).to eq(true)
        expect(dbl.same?(nil)).to eq(true)
      end
    end

    it "has a non-union return type" do
      expect(dbl.inspect).to compile_as(String)
    end
  end

  context "without common object methods" do
    subject(dbl) { Spectator::LazyDouble.new }

    it "returns the original value" do
      io = IO::Memory.new
      aggregate_failures do
        expect(dbl.!=(42)).to be_true
        expect(dbl.!~(42)).to be_true
        expect(dbl.==(42)).to be_false
        expect(dbl.===(42)).to be_false
        expect(dbl.=~(42)).to be_nil
        expect(dbl.class).to be_lt(Spectator::LazyDouble)
        expect(dbl.in?([42])).to be_false
        expect(dbl.in?(1, 2, 3)).to be_false
        expect(dbl.itself).to be(dbl)
        expect(dbl.not_nil!).to be(dbl)
        expect(dbl.tap { nil }).to be(dbl)
        expect(dbl.to_s(io)).to be_nil
        expect(dbl.try { nil }).to be_nil
        expect(dbl.same?(dbl)).to be_true
        expect(dbl.same?(nil)).to be_false
      end
    end
  end

  context "with arguments constraints" do
    let(arguments) { Spectator::Arguments.capture(/foo/) }

    context "without common object methods" do
      let(stub) { Spectator::ValueStub.new(:foo, "bar", arguments).as(Spectator::Stub) }
      subject(dbl) { Spectator::LazyDouble.new(nil, [stub], foo: "fallback") }

      it "returns the response when constraint satisfied" do
        expect(dbl.foo("foobar")).to eq("bar")
      end

      it "returns the fallback value when constraint unsatisfied" do
        expect { dbl.foo("baz") }.to eq("fallback")
      end

      it "returns the fallback value when argument count doesn't match" do
        expect { dbl.foo }.to eq("fallback")
      end
    end

    context "with common object methods" do
      let(stub) { Spectator::ValueStub.new(:"same?", true, arguments).as(Spectator::Stub) }
      subject(dbl) { Spectator::LazyDouble.new(nil, [stub]) }

      it "returns the response when constraint satisfied" do
        expect(dbl.same?("foobar")).to eq(true)
      end

      it "raises an error when constraint unsatisfied" do
        expect { dbl.same?("baz") }.to raise_error(Spectator::UnexpectedMessage)
      end

      it "raises an error when argument count doesn't match" do
        expect { dbl.same? }.to raise_error(Spectator::UnexpectedMessage)
      end

      context "with a fallback defined" do
        subject(dbl) { Spectator::LazyDouble.new(nil, [stub], "same?": true) }

        it "returns the fallback when constraint unsatisfied" do
          expect(dbl.same?("baz")).to be_true
        end
      end
    end
  end

  describe "#_spectator_define_stub" do
    subject(dbl) { Spectator::LazyDouble.new(foo: 42, bar: "baz") }
    let(stub3) { Spectator::ValueStub.new(:foo, 3) }
    let(stub5) { Spectator::ValueStub.new(:foo, 5) }
    let(stub7) { Spectator::ValueStub.new(:foo, 7, Spectator::Arguments.capture(:lucky)) }

    it "overrides an existing method" do
      expect { dbl._spectator_define_stub(stub3) }.to change { dbl.foo }.from(42).to(3)
    end

    it "replaces an existing stub" do
      dbl._spectator_define_stub(stub3)
      expect { dbl._spectator_define_stub(stub5) }.to change { dbl.foo }.from(3).to(5)
    end

    it "doesn't affect other methods" do
      expect { dbl._spectator_define_stub(stub5) }.to_not change { dbl.bar }
    end

    it "picks the correct stub based on arguments" do
      dbl._spectator_define_stub(stub5)
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo).to eq(5)
        expect(dbl.foo(:lucky)).to eq(7)
      end
    end

    it "only uses a stub if an argument constraint is met" do
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo).to eq(42)
        expect(dbl.foo(:lucky)).to eq(7)
      end
    end

    it "ignores the block argument if not in the constraint" do
      dbl._spectator_define_stub(stub5)
      dbl._spectator_define_stub(stub7)
      aggregate_failures do
        expect(dbl.foo { nil }).to eq(5)
        expect(dbl.foo(:lucky) { nil }).to eq(7)
      end
    end

    context "with previously undefined methods" do
      it "raises an error" do
        stub = Spectator::ValueStub.new(:baz, :xyz)
        expect { dbl._spectator_define_stub(stub) }.to raise_error(/stub/)
      end
    end
  end

  describe "#_spectator_clear_stubs" do
    subject(dbl) { Spectator::LazyDouble.new(foo: 42, bar: "baz") }
    let(stub) { Spectator::ValueStub.new(:foo, 5) }

    before { dbl._spectator_define_stub(stub) }

    it "removes previously defined stubs" do
      expect { dbl._spectator_clear_stubs }.to change { dbl.foo }.from(5).to(42)
    end
  end

  describe "#_spectator_calls" do
    subject(dbl) { Spectator::LazyDouble.new(foo: 42, bar: "baz") }
    let(stub) { Spectator::ValueStub.new(:foo, 5) }

    before { dbl._spectator_define_stub(stub) }

    # Retrieves symbolic names of methods called on a double.
    def called_method_names(dbl)
      dbl._spectator_calls.map(&.method)
    end

    it "stores calls to stubbed methods" do
      expect { dbl.foo }.to change { called_method_names(dbl) }.from(%i[]).to(%i[foo])
    end

    it "stores multiple calls to the same stub" do
      dbl.foo
      expect { dbl.foo }.to change { called_method_names(dbl) }.from(%i[foo]).to(%i[foo foo])
    end

    it "stores calls to non-stubbed methods" do
      expect { dbl.baz }.to raise_error(Spectator::UnexpectedMessage, /baz/)
      expect(called_method_names(dbl)).to contain(:baz)
    end

    it "stores arguments for a call" do
      dbl.foo(42)
      args = Spectator::Arguments.capture(42)
      call = dbl._spectator_calls.first
      expect(call.arguments).to eq(args)
    end
  end

  describe "#to_s" do
    subject(string) { dbl.to_s }

    context "with a name" do
      let(dbl) { Spectator::LazyDouble.new("dbl-name") }

      it "indicates it's a double" do
        expect(string).to contain("LazyDouble")
      end

      it "contains the double name" do
        expect(string).to contain("dbl-name")
      end
    end

    context "without a name" do
      let(dbl) { Spectator::LazyDouble.new }

      it "contains the double type" do
        expect(string).to contain("LazyDouble")
      end

      it "contains \"Anonymous\"" do
        expect(string).to contain("Anonymous")
      end
    end
  end

  describe "#inspect" do
    subject(string) { dbl.inspect }

    context "with a name" do
      let(dbl) { Spectator::LazyDouble.new("dbl-name") }

      it "contains the double type" do
        expect(string).to contain("LazyDouble")
      end

      it "contains the double name" do
        expect(string).to contain("dbl-name")
      end

      it "contains the object ID" do
        expect(string).to contain(dbl.object_id.to_s(16))
      end
    end

    context "without a name" do
      let(dbl) { Spectator::LazyDouble.new }

      it "contains the double type" do
        expect(string).to contain("LazyDouble")
      end

      it "contains \"Anonymous\"" do
        expect(string).to contain("Anonymous")
      end

      it "contains the object ID" do
        expect(string).to contain(dbl.object_id.to_s(16))
      end
    end
  end
end
