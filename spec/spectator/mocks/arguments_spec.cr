require "../../spec_helper"

Spectator.describe Spectator::Arguments do
  subject(arguments) { Spectator::Arguments.new({42, "foo"}, {bar: "baz", qux: 123}) }

  it "stores the arguments" do
    expect(arguments).to have_attributes(
      args: {42, "foo"},
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
  end

  describe "#[](symbol)" do
    it "returns a keyword argument" do
      aggregate_failures do
        expect(arguments[:bar]).to eq("baz")
        expect(arguments[:qux]).to eq(123)
      end
    end
  end

  describe "#to_s" do
    subject { arguments.to_s }

    it "formats the arguments" do
      is_expected.to eq("(42, \"foo\", bar: \"baz\", qux: 123)")
    end

    context "when empty" do
      let(arguments) { Spectator::Arguments.none }

      it "returns (no args)" do
        is_expected.to eq("(no args)")
      end
    end
  end

  describe "#==" do
    subject { arguments == other }

    context "with Arguments" do
      context "with equal arguments" do
        let(other) { arguments }

        it { is_expected.to be_true }
      end

      context "with different arguments" do
        let(other) { Spectator::Arguments.new({123, :foo, "bar"}, {opt: "foobar"}) }

        it { is_expected.to be_false }
      end

      context "with the same kwargs in a different order" do
        let(other) { Spectator::Arguments.new(arguments.args, {qux: 123, bar: "baz"}) }

        it { is_expected.to be_true }
      end

      context "with a missing kwarg" do
        let(other) { Spectator::Arguments.new(arguments.args, {bar: "baz"}) }

        it { is_expected.to be_false }
      end

      context "with an extra kwarg" do
        let(other) { Spectator::Arguments.new(arguments.args, {bar: "baz", qux: 123, extra: 0}) }

        it { is_expected.to be_false }
      end
    end

    context "with FormalArguments" do
      context "with equal arguments" do
        let(other) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, {bar: "baz", qux: 123}) }

        it { is_expected.to be_true }
      end

      context "with different arguments" do
        let(other) { Spectator::FormalArguments.new({arg1: 123, arg2: :foo, arg3: "bar"}, {opt: "foobar"}) }

        it { is_expected.to be_false }
      end

      context "with the same kwargs in a different order" do
        let(other) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, {qux: 123, bar: "baz"}) }

        it { is_expected.to be_true }
      end

      context "with a missing kwarg" do
        let(other) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, {bar: "baz"}) }

        it { is_expected.to be_false }
      end

      context "with an extra kwarg" do
        let(other) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, {bar: "baz", qux: 123, extra: 0}) }

        it { is_expected.to be_false }
      end

      context "with different splat arguments" do
        let(other) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {1, 2, 3}, {bar: "baz", qux: 123}) }

        it { is_expected.to be_false }
      end

      context "with mixed positional tuple types" do
        let(other) { Spectator::FormalArguments.new({arg1: 42}, :splat, {"foo"}, {bar: "baz", qux: 123}) }

        it { is_expected.to be_true }
      end
    end
  end

  describe "#===" do
    subject { pattern === arguments }

    context "with Arguments" do
      context "with equal arguments" do
        let(pattern) { arguments }

        it { is_expected.to be_true }
      end

      context "with matching arguments" do
        let(pattern) { Spectator::Arguments.new({Int32, /foo/}, {bar: /baz/, qux: Int32}) }

        it { is_expected.to be_true }
      end

      context "with non-matching arguments" do
        let(pattern) { Spectator::Arguments.new({Float64, /bar/}, {bar: /foo/, qux: "123"}) }

        it { is_expected.to be_false }
      end

      context "with different arguments" do
        let(pattern) { Spectator::Arguments.new({123, :foo, "bar"}, {opt: "foobar"}) }

        it { is_expected.to be_false }
      end

      context "with the same kwargs in a different order" do
        let(pattern) { Spectator::Arguments.new(arguments.args, {qux: Int32, bar: /baz/}) }

        it { is_expected.to be_true }
      end

      context "with an additional kwarg" do
        let(pattern) { Spectator::Arguments.new(arguments.args, {bar: /baz/}) }

        it { is_expected.to be_true }
      end

      context "with a missing kwarg" do
        let(pattern) { Spectator::Arguments.new(arguments.args, {bar: /baz/, qux: Int32, extra: 0}) }

        it { is_expected.to be_false }
      end
    end

    context "with FormalArguments" do
      let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, {bar: "baz", qux: 123}) }

      context "with equal arguments" do
        let(pattern) { Spectator::Arguments.new({42, "foo"}, {bar: "baz", qux: 123}) }

        it { is_expected.to be_true }
      end

      context "with matching arguments" do
        let(pattern) { Spectator::Arguments.new({Int32, /foo/}, {bar: /baz/, qux: Int32}) }

        it { is_expected.to be_true }
      end

      context "with non-matching arguments" do
        let(pattern) { Spectator::Arguments.new({Float64, /bar/}, {bar: /foo/, qux: "123"}) }

        it { is_expected.to be_false }
      end

      context "with different arguments" do
        let(pattern) { Spectator::Arguments.new({123, :foo, "bar"}, {opt: "foobar"}) }

        it { is_expected.to be_false }
      end

      context "with the same kwargs in a different order" do
        let(pattern) { Spectator::Arguments.new(arguments.positional, {qux: Int32, bar: /baz/}) }

        it { is_expected.to be_true }
      end

      context "with an additional kwarg" do
        let(pattern) { Spectator::Arguments.new(arguments.positional, {bar: /baz/}) }

        it { is_expected.to be_true }
      end

      context "with a missing kwarg" do
        let(pattern) { Spectator::Arguments.new(arguments.positional, {bar: /baz/, qux: Int32, extra: 0}) }

        it { is_expected.to be_false }
      end

      context "with different splat arguments" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {1, 2, 3}, super.kwargs) }
        let(pattern) { Spectator::Arguments.new({Int32, /foo/, 5}, arguments.kwargs) }

        it { is_expected.to be_false }
      end

      context "with matching mixed positional tuple types" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {1, 2, 3}, super.kwargs) }
        let(pattern) { Spectator::Arguments.new({Int32, /foo/, 1, 2, 3}, arguments.kwargs) }

        it { is_expected.to be_true }
      end

      context "with non-matching mixed positional tuple types" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {1, 2, 3}, super.kwargs) }
        let(pattern) { Spectator::Arguments.new({Float64, /bar/, 3, 2, Symbol}, arguments.kwargs) }

        it { is_expected.to be_false }
      end

      context "with matching args spilling over into splat and mixed positional tuple types" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
        let(pattern) { Spectator::Arguments.capture(Int32, /foo/, Symbol, Symbol, :z, bar: /baz/, qux: Int32) }

        it { is_expected.to be_true }
      end

      context "with non-matching args spilling over into splat and mixed positional tuple types" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
        let(pattern) { Spectator::Arguments.capture(Float64, /bar/, Symbol, String, :z, bar: /foo/, qux: Int32) }

        it { is_expected.to be_false }
      end

      context "with matching mixed named positional and keyword arguments" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
        let(pattern) { Spectator::Arguments.capture(/foo/, Symbol, :y, Symbol, arg1: Int32, bar: /baz/, qux: 123) }

        it { is_expected.to be_true }
      end

      context "with non-matching mixed named positional and keyword arguments" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
        let(pattern) { Spectator::Arguments.capture(5, Symbol, :z, Symbol, arg2: /foo/, bar: /baz/, qux: Int32) }

        it { is_expected.to be_false }
      end

      context "with non-matching mixed named positional and keyword arguments" do
        let(arguments) { Spectator::FormalArguments.new({arg1: 42, arg2: "foo"}, :splat, {:x, :y, :z}, {bar: "baz", qux: 123}) }
        let(pattern) { Spectator::Arguments.capture(/bar/, String, :y, Symbol, arg1: 0, bar: /foo/, qux: Float64) }

        it { is_expected.to be_false }
      end
    end
  end
end
