require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/be-within-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`be_within` matcher" do
  context "basic usage" do
    describe 27.5 do
      it { is_expected.to be_within(0.5).of(27.9) }
      it { is_expected.to be_within(0.5).of(28.0) }
      it { is_expected.to be_within(0.5).of(27.1) }
      it { is_expected.to be_within(0.5).of(27.0) }

      it { is_expected.not_to be_within(0.5).of(28.1) }
      it { is_expected.not_to be_within(0.5).of(26.9) }

      # deliberate failures
      it_fails { is_expected.not_to be_within(0.5).of(28) }
      it_fails { is_expected.not_to be_within(0.5).of(27) }
      it_fails { is_expected.to be_within(0.5).of(28.1) }
      it_fails { is_expected.to be_within(0.5).of(26.9) }
    end
  end
end
