require "../../spec_helper"

Spectator.describe Spectator::Arguments do
  subject(arguments) do
    Spectator::Arguments.new(
      args: {42, "foo"},
      kwargs: {bar: "baz", qux: 123}
    )
  end

  it "stores the arguments" do
    expect(arguments.args).to eq({42, "foo"})
  end

  it "stores the keyword arguments" do
    expect(arguments.kwargs).to eq({bar: "baz", qux: 123})
  end

  describe ".capture" do
    subject { Spectator::Arguments.capture(42, "foo", bar: "baz", qux: 123) }

    it "stores the arguments and keyword arguments" do
      is_expected.to have_attributes(args: {42, "foo"}, kwargs: {bar: "baz", qux: 123})
    end
  end

  describe "#[]" do
    context "with an index" do
      it "returns a positional argument" do
        aggregate_failures do
          expect(arguments[0]).to eq(42)
          expect(arguments[1]).to eq("foo")
        end
      end
    end

    context "with a symbol" do
      it "returns a named argument" do
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
      is_expected.to eq("(42, \"foo\", bar: \"baz\", qux: 123)")
    end

    context "when empty" do
      let(arguments) { Spectator::Arguments.empty }

      it "returns (no args)" do
        is_expected.to eq("(no args)")
      end
    end
  end

  describe "#==" do
    subject { arguments == other }

    context "with equal arguments" do
      let(other) { arguments }

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with different arguments" do
      let(other) do
        Spectator::Arguments.new(
          args: {123, :foo, "bar"},
          kwargs: {opt: "foobar"}
        )
      end

      it "returns false" do
        is_expected.to be_false
      end
    end

    context "with the same kwargs in a different order" do
      let(other) do
        Spectator::Arguments.new(
          args: arguments.args,
          kwargs: {qux: 123, bar: "baz"}
        )
      end

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with a missing kwarg" do
      let(other) do
        Spectator::Arguments.new(
          args: arguments.args,
          kwargs: {bar: "baz"}
        )
      end

      it "returns false" do
        is_expected.to be_false
      end
    end
  end

  describe "#===" do
    subject { pattern === arguments }

    context "with equal arguments" do
      let(pattern) { arguments }

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with different arguments" do
      let(pattern) do
        Spectator::Arguments.new(
          args: {123, :foo, "bar"},
          kwargs: {opt: "foobar"}
        )
      end

      it "returns false" do
        is_expected.to be_false
      end
    end

    context "with the same kwargs in a different order" do
      let(pattern) do
        Spectator::Arguments.new(
          args: arguments.args,
          kwargs: {qux: 123, bar: "baz"}
        )
      end

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with a missing kwarg" do
      let(pattern) do
        Spectator::Arguments.new(
          args: arguments.args,
          kwargs: {bar: "baz"}
        )
      end

      it "returns false" do
        is_expected.to be_false
      end
    end

    context "with matching types and regex" do
      let(pattern) do
        Spectator::Arguments.new(
          args: {Int32, /foo/},
          kwargs: {bar: String, qux: 123}
        )
      end

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with different types and regex" do
      let(pattern) do
        Spectator::Arguments.new(
          args: {Symbol, /bar/},
          kwargs: {bar: String, qux: 42}
        )
      end

      it "returns false" do
        is_expected.to be_false
      end
    end
  end
end
