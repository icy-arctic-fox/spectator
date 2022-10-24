require "../../spec_helper"

Spectator.describe Spectator::Arguments do
  subject(arguments) { Spectator::Arguments.new({42, "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

  it "stores the arguments" do
    expect(arguments).to have_attributes(
      args: {42, "foo"},
      splat_name: :splat,
      splat: {:x, :y, :z},
      kwargs: {bar: "baz", qux: 123}
    )
  end

  describe ".capture" do
    subject { Spectator::Arguments.capture(42, "foo", bar: "baz", qux: 123) }

    it "stores the arguments and keyword arguments" do
      is_expected.to have_attributes(args: {42, "foo"}, kwargs: {bar: "baz", qux: 123})
    end
  end

  describe "#[](index)" do
    it "returns a positional argument" do
      aggregate_failures do
        expect(arguments[0]).to eq(42)
        expect(arguments[1]).to eq("foo")
      end
    end

    it "returns splat arguments" do
      aggregate_failures do
        expect(arguments[2]).to eq(:x)
        expect(arguments[3]).to eq(:y)
        expect(arguments[4]).to eq(:z)
      end
    end

    context "with named positional arguments" do
      subject(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

      it "returns a positional argument" do
        aggregate_failures do
          expect(arguments[0]).to eq(42)
          expect(arguments[1]).to eq("foo")
        end
      end

      it "returns splat arguments" do
        aggregate_failures do
          expect(arguments[2]).to eq(:x)
          expect(arguments[3]).to eq(:y)
          expect(arguments[4]).to eq(:z)
        end
      end
    end
  end

  describe "#[](symbol)" do
    it "returns a keyword argument" do
      aggregate_failures do
        expect(arguments[:bar]).to eq("baz")
        expect(arguments[:qux]).to eq(123)
      end
    end

    context "with named positional arguments" do
      subject(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

      it "returns a positional argument" do
        aggregate_failures do
          expect(arguments[:arg1]).to eq(42)
          expect(arguments[:arg2]).to eq("foo")
        end
      end

      it "returns a keyword argument" do
        aggregate_failures do
          expect(arguments[:bar]).to eq("baz")
          expect(arguments[:qux]).to eq(123)
        end
      end
    end
  end

  describe "#to_s" do
    subject { arguments.to_s }

    it "formats the arguments" do
      is_expected.to eq("(42, \"foo\", *splat: {:x, :y, :z}, bar: \"baz\", qux: 123)")
    end

    context "when empty" do
      let(arguments) { Spectator::Arguments.none }

      it "returns (no args)" do
        is_expected.to eq("(no args)")
      end
    end

    context "with a splat and no arguments" do
      let(arguments) { Spectator::Arguments.build(NamedTuple.new, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

      it "omits the splat name" do
        is_expected.to eq("(:x, :y, :z, bar: \"baz\", qux: 123)")
      end
    end
  end

  describe "#==" do
    subject { arguments == other }

    context "with equal arguments" do
      let(other) { arguments }

      it { is_expected.to be_true }
    end

    context "with different arguments" do
      let(other) { Spectator::Arguments.new({123, :foo, "bar"}, :splat, {1, 2, 3}, {opt: "foobar"}) }

      it { is_expected.to be_false }
    end

    context "with the same kwargs in a different order" do
      let(other) { Spectator::Arguments.new(arguments.args, arguments.splat_name, arguments.splat, {qux: 123, bar: "baz"}) }

      it { is_expected.to be_true }
    end

    context "with a missing kwarg" do
      let(other) { Spectator::Arguments.new(arguments.args, arguments.splat_name, arguments.splat, {bar: "baz"}) }

      it { is_expected.to be_false }
    end

    context "with an extra kwarg" do
      let(other) { Spectator::Arguments.new(arguments.args, arguments.splat_name, arguments.splat, {bar: "baz", qux: 123, extra: 0}) }

      it { is_expected.to be_false }
    end

    context "with different splat arguments" do
      let(other) { Spectator::Arguments.new(arguments.args, arguments.splat_name, {1, 2, 3}, arguments.kwargs) }

      it { is_expected.to be_false }
    end

    context "with mixed positional tuple types" do
      let(other) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, arguments.splat_name, arguments.splat, arguments.kwargs) }

      it { is_expected.to be_true }
    end

    context "with mixed positional tuple types (flipped)" do
      let(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
      let(other) { Spectator::Arguments.new({42, "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

      it { is_expected.to be_true }
    end

    context "with args spilling over into splat and mixed positional tuple types" do
      let(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
      let(other) { Spectator::Arguments.new({42, "foo", :x, :y, :z}, nil, nil, {bar: "baz", qux: 123}) }

      it { is_expected.to be_true }
    end
  end

  describe "#===" do
    subject { pattern === arguments }

    context "with equal arguments" do
      let(pattern) { arguments }

      it { is_expected.to be_true }
    end

    context "with matching arguments" do
      let(pattern) { Spectator::Arguments.new({Int32, /foo/}, :splat, {Symbol, Symbol, :z}, {bar: /baz/, qux: Int32}) }

      it { is_expected.to be_true }
    end

    context "with non-matching arguments" do
      let(pattern) { Spectator::Arguments.new({Float64, /bar/}, :splat, {String, Int32, :x}, {bar: /foo/, qux: "123"}) }

      it { is_expected.to be_false }
    end

    context "with different arguments" do
      let(pattern) { Spectator::Arguments.new({123, :foo, "bar"}, :splat, {1, 2, 3}, {opt: "foobar"}) }

      it { is_expected.to be_false }
    end

    context "with the same kwargs in a different order" do
      let(pattern) { Spectator::Arguments.new(arguments.args, arguments.splat_name, arguments.splat, {qux: Int32, bar: /baz/}) }

      it { is_expected.to be_true }
    end

    context "with an additional kwarg" do
      let(pattern) { Spectator::Arguments.new(arguments.args, arguments.splat_name, arguments.splat, {bar: /baz/}) }

      it { is_expected.to be_true }
    end

    context "with a missing kwarg" do
      let(pattern) { Spectator::Arguments.new(arguments.args, arguments.splat_name, arguments.splat, {bar: /baz/, qux: Int32, extra: 0}) }

      it { is_expected.to be_false }
    end

    context "with different splat arguments" do
      let(pattern) { Spectator::Arguments.new(arguments.args, arguments.splat_name, {1, 2, 3}, arguments.kwargs) }

      it { is_expected.to be_false }
    end

    context "with matching mixed positional tuple types" do
      let(pattern) { Spectator::Arguments.new({arg1: Int32, arg2: /foo/}, arguments.splat_name, arguments.splat, arguments.kwargs) }

      it { is_expected.to be_true }
    end

    context "with non-matching mixed positional tuple types" do
      let(pattern) { Spectator::Arguments.new({arg1: Float64, arg2: /bar/}, arguments.splat_name, arguments.splat, arguments.kwargs) }

      it { is_expected.to be_false }
    end

    context "with matching args spilling over into splat and mixed positional tuple types" do
      let(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
      let(pattern) { Spectator::Arguments.capture(Int32, /foo/, Symbol, Symbol, :z, bar: /baz/, qux: Int32) }

      it { is_expected.to be_true }
    end

    context "with non-matching args spilling over into splat and mixed positional tuple types" do
      let(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
      let(pattern) { Spectator::Arguments.capture(Float64, /bar/, Symbol, String, :z, bar: /foo/, qux: Int32) }

      it { is_expected.to be_false }
    end

    context "with matching mixed named positional and keyword arguments" do
      let(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
      let(pattern) { Spectator::Arguments.capture(/foo/, Symbol, :y, Symbol, arg1: Int32, bar: /baz/, qux: 123) }

      it { is_expected.to be_true }
    end

    context "with non-matching mixed named positional and keyword arguments" do
      let(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
      let(pattern) { Spectator::Arguments.capture(5, Symbol, :z, Symbol, arg2: /foo/, bar: /baz/, qux: Int32) }

      it { is_expected.to be_false }
    end

    context "with non-matching mixed named positional and keyword arguments" do
      let(arguments) { Spectator::Arguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
      let(pattern) { Spectator::Arguments.capture(/bar/, String, :y, Symbol, arg1: 0, bar: /foo/, qux: Float64) }

      it { is_expected.to be_false }
    end
  end
end
