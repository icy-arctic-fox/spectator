require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/start-with-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`start_with` matcher" do
  context "with a string" do
    describe "this string" do
      it { is_expected.to start_with "this" }
      it { is_expected.not_to start_with "that" }

      # deliberate failures
      it_fails { is_expected.not_to start_with "this" }
      it_fails { is_expected.to start_with "that" }
    end
  end

  context "with an array" do
    describe [0, 1, 2, 3, 4] do
      it { is_expected.to start_with 0 }
      skip reason: "Add support for multiple items at the beginning of an array." { is_expected.to start_with(0, 1) }
      it { is_expected.not_to start_with(2) }
      skip reason: "Add support for multiple items at the beginning of an array." { is_expected.not_to start_with(0, 1, 2, 3, 4, 5) }

      # deliberate failures
      it_fails { is_expected.not_to start_with 0 }
      it_fails { is_expected.to start_with 3 }
    end
  end
end
