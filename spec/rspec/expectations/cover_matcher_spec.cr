require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/cover-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`cover` matcher" do
  context "range usage" do
    describe (1..10) do
      it { is_expected.to cover(4) }
      it { is_expected.to cover(6) }
      it { is_expected.to cover(8) }
      it { is_expected.to cover(4, 6) }
      it { is_expected.to cover(4, 6, 8) }
      it { is_expected.not_to cover(11) }
      it { is_expected.not_to cover(11, 12) }

      # deliberate failures
      it_fails { is_expected.to cover(11) }
      it_fails { is_expected.not_to cover(4) }
      it_fails { is_expected.not_to cover(6) }
      it_fails { is_expected.not_to cover(8) }
      it_fails { is_expected.not_to cover(4, 6, 8) }

      # both of these should fail since it covers 5 but not 11
      it_fails { is_expected.to cover(5, 11) }
      it_fails { is_expected.not_to cover(5, 11) }
    end
  end
end
