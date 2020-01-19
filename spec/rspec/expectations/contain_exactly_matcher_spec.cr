require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/contain-exactly-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`contain_exactly` matcher" do
  context "Array is expected to contain every value" do
    describe [1, 2, 3] do
      it { is_expected.to contain_exactly(1, 2, 3) }
      it { is_expected.to contain_exactly(1, 3, 2) }
      it { is_expected.to contain_exactly(2, 1, 3) }
      it { is_expected.to contain_exactly(2, 3, 1) }
      it { is_expected.to contain_exactly(3, 1, 2) }
      it { is_expected.to contain_exactly(3, 2, 1) }

      # deliberate failures
      it_fails { is_expected.to contain_exactly(1, 2, 1) }
    end
  end

  context "Array is not expected to contain every value" do
    describe [1, 2, 3] do
      it { is_expected.to_not contain_exactly(1, 2, 3, 4) }
      it { is_expected.to_not contain_exactly(1, 2) }

      # deliberate failures
      it_fails { is_expected.to_not contain_exactly(1, 3, 2) }
    end
  end
end
