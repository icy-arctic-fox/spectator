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
      is_expected.to eq("(42, \"foo\", *splat: {:x, :y, :z}, bar: \"baz\", qux: 123)")
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

    context "with equal arguments" do
      let(other) { arguments }

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with different arguments" do
      let(other) { Spectator::Arguments.new({123, :foo, "bar"}, nil, nil, {opt: "foobar"}) }

      it "returns false" do
        is_expected.to be_false
      end
    end

    context "with the same kwargs in a different order" do
      let(other) { Spectator::Arguments.new(arguments.args, nil, nil, {qux: 123, bar: "baz"}) }

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with a missing kwarg" do
      let(other) { Spectator::Arguments.new(arguments.args, nil, nil, {bar: "baz"}) }

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
      let(pattern) { Spectator::Arguments.new({123, :foo, "bar"}, nil, nil, {opt: "foobar"}) }

      it "returns false" do
        is_expected.to be_false
      end
    end

    context "with the same kwargs in a different order" do
      let(pattern) { Spectator::Arguments.new(arguments.args, nil, nil, {qux: 123, bar: "baz"}) }

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with a missing kwarg" do
      let(pattern) { Spectator::Arguments.new(arguments.args, nil, nil, {bar: "baz"}) }

      it "returns false" do
        is_expected.to be_false
      end
    end

    context "with matching types and regex" do
      let(pattern) { Spectator::Arguments.new({Int32, /foo/}, nil, nil, {bar: String, qux: 123}) }

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with different types and regex" do
      let(pattern) { Spectator::Arguments.new({Symbol, /bar/}, nil, nil, {bar: String, qux: 42}) }

      it "returns false" do
        is_expected.to be_false
      end
    end
  end
end
