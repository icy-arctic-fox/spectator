require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/end-with-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`end_with` matcher" do
  context "string usage" do
    describe "this string" do
      it { is_expected.to end_with "string" }
      it { is_expected.not_to end_with "stringy" }

      # deliberate failures
      # TODO: Add support for expected failures.
      xit { is_expected.not_to end_with "string" }
      xit { is_expected.to end_with "stringy" }
    end
  end

  context "array usage" do
    describe [0, 1, 2, 3, 4] do
      it { is_expected.to end_with 4 }
      # TODO: Add support for multiple items at the end of an array.
      # it { is_expected.to end_with 3, 4 }
      it { is_expected.not_to end_with 3 }
      # it { is_expected.not_to end_with 0, 1, 2, 3, 4, 5 }

      # deliberate failures
      # TODO: Add support for expected failures.
      xit { is_expected.not_to end_with 4 }
      xit { is_expected.to end_with 3 }
    end
  end
end
