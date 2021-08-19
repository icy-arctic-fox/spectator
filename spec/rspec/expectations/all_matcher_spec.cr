require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/all-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`all` matcher" do
  context "array usage" do
    describe [1, 3, 5] do
      it { is_expected.to all(be_odd) }
      it { is_expected.to all(be_an(Int32)) } # Changed to Int32 to satisfy compiler.
      it { is_expected.to all(be < 10) }

      # deliberate failures
      it_fails { is_expected.to all(be_even) }
      it_fails { is_expected.to all(be_a(String)) }
      it_fails { is_expected.to all(be > 2) }
    end
  end

  context "compound matcher usage" do
    # Changed `include` to `contain` to match our own.
    # `include` is a keyword and can't be used as a method name in Crystal.

    describe ["anything", "everything", "something"] do
      skip reason: "Add support for compound matchers." { is_expected.to all(be_a(String).and contain("thing")) }
      skip reason: "Add support for compound matchers." { is_expected.to all(be_a(String).and end_with("g")) }
      skip reason: "Add support for compound matchers." { is_expected.to all(start_with("s").or contain("y")) }

      # deliberate failures
      skip reason: "Add support for compound matchers." { is_expected.to all(contain("foo").and contain("bar")) }
      skip reason: "Add support for compound matchers." { is_expected.to all(be_a(String).and start_with("a")) }
      skip reason: "Add support for compound matchers." { is_expected.to all(start_with("a").or contain("z")) }
    end
  end
end
