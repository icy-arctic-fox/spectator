require "../../spec_helper"

Spectator.describe Spectator::Double do
  subject(dbl) { Spectator::Double({foo: Int32, bar: String}).new("dbl-name", foo: 42, bar: "baz") }

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
    expect { dbl.baz }.to raise_error(/dbl-name/)
  end

  it "reports arguments" do
    expect { dbl.baz(123, "qux", field: :value) }.to raise_error(Spectator::UnexpectedMessage, /\(123, "qux", field: :value\)/)
  end

  context "without a double name" do
    subject(dbl) { Spectator::Double.new(foo: 42) }

    it "reports as anonymous" do
      expect { dbl.baz }.to raise_error(/anonymous/i)
    end
  end

  context "with common object methods" do
    subject(dbl) do
      Spectator::Double.new(
        "!=": "!=",
        "!~": "!~",
        "==": "==",
        "===": "===",
        "=~": "=~",
        "class": "class",
        "dup": "dup",
        "hash": "hash",
        "in?": true,
        "inspect": "inspect",
        "itself": "itself",
        "not_nil!": "not_nil!",
        "pretty_inspect": "pretty_inspect",
        "tap": "tap",
        "to_json": "to_json",
        "to_pretty_json": "to_pretty_json",
        "to_s": "to_s",
        "to_yaml": "to_yaml",
        "try": "try",
        "object_id": 42_u64,
        "same?": false,
      )
    end

    it "responds with defined messages" do
      aggregate_failures do
        expect(dbl.!=(42)).to eq("!=")
        expect(dbl.!~(42)).to eq("!~")
        expect(dbl.==(42)).to eq("==")
        expect(dbl.===(42)).to eq("===")
        expect(dbl.=~(42)).to eq("=~")
        expect(dbl.class).to eq("class")
        expect(dbl.dup).to eq("dup")
        expect(dbl.hash(42)).to eq("hash")
        expect(dbl.hash).to eq("hash")
        expect(dbl.in?(42)).to eq(true)
        expect(dbl.in?(1, 2, 3)).to eq(true)
        expect(dbl.inspect).to eq("inspect")
        expect(dbl.itself).to eq("itself")
        expect(dbl.not_nil!).to eq("not_nil!")
        expect(dbl.pretty_inspect).to eq("pretty_inspect")
        expect(dbl.tap { nil }).to eq("tap")
        expect(dbl.to_json).to eq("to_json")
        expect(dbl.to_pretty_json).to eq("to_pretty_json")
        expect(dbl.to_s).to eq("to_s")
        expect(dbl.to_yaml).to eq("to_yaml")
        expect(dbl.try { nil }).to eq("try")
        expect(dbl.object_id).to eq(42_u64)
        expect(dbl.same?(dbl)).to eq(false)
        expect(dbl.same?(nil)).to eq(false)
      end
    end
  end

  context "without common object methods" do
    subject(dbl) { Spectator::Double.new }

    it "raises with undefined messages" do
      io = IO::Memory.new
      pp = PrettyPrint.new(io)
      aggregate_failures do
        expect { dbl.!=(42) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.!~(42) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.==(42) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.===(42) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.=~(42) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.class }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.dup }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.hash(42) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.hash }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.in?(42) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.in?(1, 2, 3) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.inspect }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.itself }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.not_nil! }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.pretty_inspect }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.pretty_inspect(io) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.pretty_print(pp) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.tap { nil } }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.to_json }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.to_json(io) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.to_pretty_json }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.to_pretty_json(io) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.to_s }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.to_s(io) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.to_yaml }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.to_yaml(io) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.try { nil } }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.object_id }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.same?(dbl) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
        expect { dbl.same?(nil) }.to raise_error(Spectator::UnexpectedMessage, /mask/)
      end
    end

    it "reports arguments" do
      expect { dbl.same?(123) }.to raise_error(Spectator::UnexpectedMessage, /\(123\)/)
    end
  end

  context "with arguments constraints" do
    let(arguments) { Spectator::Arguments.capture(/foo/) }
    let(stub) { Spectator::ValueStub.new(:foo, "bar", arguments).as(Spectator::Stub) }
    subject(dbl) { Spectator::Double({foo: String}).new([stub]) }

    it "returns the response when constraint satisfied" do
      expect(dbl.foo("foobar")).to eq("bar")
    end

    it "raises an error when constraint unsatisfied" do
      expect { dbl.foo("baz") }.to raise_error(Spectator::UnexpectedMessage)
    end

    it "raises an error when argument count doesn't match" do
      expect { dbl.foo }.to raise_error(Spectator::UnexpectedMessage)
    end

    context "with common object methods" do
      let(stub) { Spectator::ValueStub.new(:"same?", true, arguments).as(Spectator::Stub) }
      subject(dbl) { Spectator::Double({"same?": Bool}).new([stub]) }

      it "returns the response when constraint satisfied" do
        expect(dbl.same?("foobar")).to eq(true)
      end

      it "raises an error when constraint unsatisfied" do
        expect { dbl.same?("baz") }.to raise_error(Spectator::UnexpectedMessage, /mask/)
      end

      it "raises an error when argument count doesn't match" do
        expect { dbl.same? }.to raise_error(Spectator::UnexpectedMessage)
      end
    end
  end
end
