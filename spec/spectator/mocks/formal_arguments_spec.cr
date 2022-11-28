require "../../spec_helper"

Spectator.describe Spectator::FormalArguments do
  subject(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

  it "stores the arguments" do
    expect(arguments).to have_attributes(
      args: {arg1: 42, arg2: "foo"},
      splat_name: :splat,
      splat: {:x, :y, :z},
      kwargs: {bar: "baz", qux: 123}
    )
  end

  describe ".build" do
    subject { Spectator::FormalArguments.build({arg1: 42, arg2: "foo"}, :splat, {1, 2, 3}, {bar: "baz", qux: 123}) }

    it "stores the arguments and keyword arguments" do
      is_expected.to have_attributes(
        args: {arg1: 42, arg2: "foo"},
        splat_name: :splat,
        splat: {1, 2, 3},
        kwargs: {bar: "baz", qux: 123}
      )
    end

    context "without a splat" do
      subject { Spectator::FormalArguments.build({arg1: 42, arg2: "foo"}, {bar: "baz", qux: 123}) }

      it "stores the arguments and keyword arguments" do
        is_expected.to have_attributes(
          args: {arg1: 42, arg2: "foo"},
          splat: nil,
          kwargs: {bar: "baz", qux: 123}
        )
      end
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
      subject(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

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
      subject(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

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
      is_expected.to eq("(arg1: 42, arg2: \"foo\", *splat: {:x, :y, :z}, bar: \"baz\", qux: 123)")
    end

    context "when empty" do
      let(arguments) { Spectator::FormalArguments.none }

      it "returns (no args)" do
        is_expected.to eq("(no args)")
      end
    end

    context "with a splat and no arguments" do
      let(arguments) { Spectator::FormalArguments.build(NamedTuple.new, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

      it "omits the splat name" do
        is_expected.to eq("(:x, :y, :z, bar: \"baz\", qux: 123)")
      end
    end
  end

  describe "#==" do
    subject { arguments == other }

    context "with Arguments" do
      context "with equal arguments" do
        let(other) { Spectator::Arguments.new(arguments.positional, arguments.kwargs) }

        it { is_expected.to be_true }
      end

      context "with different arguments" do
        let(other) { Spectator::Arguments.new({123, :foo, "bar"}, {opt: "foobar"}) }

        it { is_expected.to be_false }
      end

      context "with the same kwargs in a different order" do
        let(other) { Spectator::Arguments.new(arguments.positional, {qux: 123, bar: "baz"}) }

        it { is_expected.to be_true }
      end

      context "with a missing kwarg" do
        let(other) { Spectator::Arguments.new(arguments.positional, {bar: "baz"}) }

        it { is_expected.to be_false }
      end

      context "with an extra kwarg" do
        let(other) { Spectator::Arguments.new(arguments.positional, {bar: "baz", qux: 123, extra: 0}) }

        it { is_expected.to be_false }
      end
    end

    context "with FormalArguments" do
      context "with equal arguments" do
        let(other) { arguments }

        it { is_expected.to be_true }
      end

      context "with different arguments" do
        let(other) { Spectator::FormalArguments.new({arg1: 123, arg2: :foo, arg3: "bar"}, :splat, {1, 2, 3}, {opt: "foobar"}) }

        it { is_expected.to be_false }
      end

      context "with the same kwargs in a different order" do
        let(other) { Spectator::FormalArguments.new(arguments.args, arguments.splat_name, arguments.splat, {qux: 123, bar: "baz"}) }

        it { is_expected.to be_true }
      end

      context "with a missing kwarg" do
        let(other) { Spectator::FormalArguments.new(arguments.args, arguments.splat_name, arguments.splat, {bar: "baz"}) }

        it { is_expected.to be_false }
      end

      context "with an extra kwarg" do
        let(other) { Spectator::FormalArguments.new(arguments.args, arguments.splat_name, arguments.splat, {bar: "baz", qux: 123, extra: 0}) }

        it { is_expected.to be_false }
      end

      context "with different splat arguments" do
        let(other) { Spectator::FormalArguments.new(arguments.args, arguments.splat_name, {1, 2, 3}, arguments.kwargs) }

        it { is_expected.to be_false }
      end

      context "with mixed positional tuple types" do
        let(other) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, arguments.splat_name, arguments.splat, arguments.kwargs) }

        it { is_expected.to be_true }
      end

      context "with mixed positional tuple types (flipped)" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
        let(other) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }

        it { is_expected.to be_true }
      end
    end
  end

  describe "#===" do
    subject { pattern === arguments }

    context "with Arguments" do
      let(arguments) { Spectator::Arguments.new({42, "foo"}, {bar: "baz", qux: 123}) }

      context "with equal arguments" do
        let(pattern) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, {bar: "baz", qux: 123}) }

        it { is_expected.to be_true }
      end

      context "with matching arguments" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Int32, arg2: /foo/}, {bar: /baz/, qux: Int32}) }

        it { is_expected.to be_true }
      end

      context "with non-matching arguments" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Float64, arg2: /bar/}, {bar: /foo/, qux: "123"}) }

        it { is_expected.to be_false }
      end

      context "with different arguments" do
        let(pattern) { Spectator::FormalArguments.new({arg1: 123, arg2: :foo, arg3: "bar"}, {opt: "foobar"}) }

        it { is_expected.to be_false }
      end

      context "with the same kwargs in a different order" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Int32, arg2: /foo/}, {qux: Int32, bar: /baz/}) }

        it { is_expected.to be_true }
      end

      context "with an additional kwarg" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Int32, arg2: /foo/}, {bar: /baz/}) }

        it { is_expected.to be_true }
      end

      context "with a missing kwarg" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Int32, arg2: /foo/}, {bar: /baz/, qux: Int32, extra: 0}) }

        it { is_expected.to be_false }
      end
    end

    context "with FormalArguments" do
      context "with equal arguments" do
        let(pattern) { arguments }

        it { is_expected.to be_true }
      end

      context "with matching arguments" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Int32, arg2: /foo/}, :splat, {Symbol, Symbol, :z}, {bar: /baz/, qux: Int32}) }

        it { is_expected.to be_true }
      end

      context "with non-matching arguments" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Float64, arg2: /bar/}, :splat, {String, Int32, :x}, {bar: /foo/, qux: "123"}) }

        it { is_expected.to be_false }
      end

      context "with different arguments" do
        let(pattern) { Spectator::FormalArguments.new({arg1: 123, arg2: :foo, arg3: "bar"}, :splat, {1, 2, 3}, {opt: "foobar"}) }

        it { is_expected.to be_false }
      end

      context "with the same kwargs in a different order" do
        let(pattern) { Spectator::FormalArguments.new(arguments.args, arguments.splat_name, arguments.splat, {qux: Int32, bar: /baz/}) }

        it { is_expected.to be_true }
      end

      context "with an additional kwarg" do
        let(pattern) { Spectator::FormalArguments.new(arguments.args, arguments.splat_name, arguments.splat, {bar: /baz/}) }

        it { is_expected.to be_true }
      end

      context "with a missing kwarg" do
        let(pattern) { Spectator::FormalArguments.new(arguments.args, arguments.splat_name, arguments.splat, {bar: /baz/, qux: Int32, extra: 0}) }

        it { is_expected.to be_false }
      end

      context "with different splat arguments" do
        let(pattern) { Spectator::FormalArguments.new(arguments.args, arguments.splat_name, {1, 2, 3}, arguments.kwargs) }

        it { is_expected.to be_false }
      end

      context "with matching mixed positional tuple types" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Int32, arg2: /foo/}, arguments.splat_name, arguments.splat, arguments.kwargs) }

        it { is_expected.to be_true }
      end

      context "with non-matching mixed positional tuple types" do
        let(pattern) { Spectator::FormalArguments.new({arg1: Float64, arg2: /bar/}, arguments.splat_name, arguments.splat, arguments.kwargs) }

        it { is_expected.to be_false }
      end
    end
  end
end
