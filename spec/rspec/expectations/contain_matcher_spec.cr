require "../../spec_helper"

# In Ruby, this is the `include` matcher.
# However, `include` is a reserved keyword in Crystal.
# So instead, it is `contain` in Spectator.
Spectator.describe "`contain` matcher" do
  context "array usage" do
    describe [1, 3, 7] do
      it { is_expected.to contain(1) }
      it { is_expected.to contain(3) }
      it { is_expected.to contain(7) }
      it { is_expected.to contain(1, 7) }
      it { is_expected.to contain(1, 3, 7) }

      # Utility matcher method `a_kind_of` is not supported.
      # it { is_expected.to contain(a_kind_of(Int)) }

      # TODO: Compound matchers aren't supported.
      # it { is_expected.to contain(be_odd.and be < 10) }

      # TODO: Fix behavior and cleanup output.
      # This syntax is allowed, but produces a wrong result and bad output.
      xit { is_expected.to contain(be_odd) }
      xit { is_expected.not_to contain(be_even) }

      it { is_expected.not_to contain(17) }
      it { is_expected.not_to contain(43, 100) }

      # deliberate failures
      # TODO: Add support for expected failures.
      xit { is_expected.to contain(4) }
      xit { is_expected.to contain(be_even) }
      xit { is_expected.not_to contain(1) }
      xit { is_expected.not_to contain(3) }
      xit { is_expected.not_to contain(7) }
      xit { is_expected.not_to contain(1, 3, 7) }

      # both of these should fail since it contains 1 but not 9
      xit { is_expected.to contain(1, 9) }
      xit { is_expected.not_to contain(1, 9) }
    end
  end

  context "string usage" do
    describe "a string" do
      it { is_expected.to contain("str") }
      it { is_expected.to contain("a", "str", "ng") }
      it { is_expected.not_to contain("foo") }
      it { is_expected.not_to contain("foo", "bar") }

      # deliberate failures
      # TODO: Add support for expected failures.
      xit { is_expected.to contain("foo") }
      xit { is_expected.not_to contain("str") }
      xit { is_expected.to contain("str", "foo") }
      xit { is_expected.not_to contain("str", "foo") }
    end
  end

  context "hash usage" do
    # A hash can't be described inline here for some reason.
    # So it is placed in the subject instead.
    describe ":a => 7, :b => 5" do
      subject { {:a => 7, :b => 5} }

      # Hash syntax is changed here from `:a => 7` to `a: 7`.
      xit { is_expected.to contain(:a) }
      xit { is_expected.to contain(:b, :a) }

      # TODO: This hash-like syntax isn't supported.
      # it { is_expected.to contain(a: 7) }
      # it { is_expected.to contain(b: 5, a: 7) }
      xit { is_expected.not_to contain(:c) }
      xit { is_expected.not_to contain(:c, :d) }
      # it { is_expected.not_to contain(d: 2) }
      # it { is_expected.not_to contain(a: 5) }
      # it { is_expected.not_to contain(b: 7, a: 5) }

      # deliberate failures
      # TODO: Add support for expected failures.
      xit { is_expected.not_to contain(:a) }
      xit { is_expected.not_to contain(:b, :a) }
      # it { is_expected.not_to contain(a: 7) }
      # it { is_expected.not_to contain(a: 7, b: 5) }
      xit { is_expected.to contain(:c) }
      xit { is_expected.to contain(:c, :d) }
      # it { is_expected.to contain(d: 2) }
      # it { is_expected.to contain(a: 5) }
      # it { is_expected.to contain(a: 5, b: 7) }

      # Mixed cases--the hash contains one but not the other.
      # All 4 of these cases should fail.
      xit { is_expected.to contain(:a, :d) }
      xit { is_expected.not_to contain(:a, :d) }
      # it { is_expected.to contain(a: 7, d: 3) }
      # it { is_expected.not_to contain(a: 7, d: 3) }
    end
  end
end
