require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/match-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`match` matcher" do
  context "string usage" do
    describe "a string" do
      it { is_expected.to match(/str/) }
      it { is_expected.not_to match(/foo/) }

      # deliberate failures
      it_fails { is_expected.not_to match(/str/) }
      it_fails { is_expected.to match(/foo/) }
    end
  end

  context "regular expression usage" do
    describe /foo/ do
      it { is_expected.to match("food") }
      it { is_expected.not_to match("drinks") }

      # deliberate failures
      it_fails { is_expected.not_to match("food") }
      it_fails { is_expected.to match("drinks") }
    end
  end
end
