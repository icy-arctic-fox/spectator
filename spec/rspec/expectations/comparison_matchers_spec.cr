require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/comparison-matchers
# and modified to fit Spectator and Crystal.
Spectator.describe "Comparison matchers" do
  context "numeric operator matchers" do
    describe 18 do
      it { is_expected.to be < 20 }
      it { is_expected.to be > 15 }
      it { is_expected.to be <= 19 }
      it { is_expected.to be >= 17 }

      # deliberate failures
      it_fails { is_expected.to be < 15 }
      it_fails { is_expected.to be > 20 }
      it_fails { is_expected.to be <= 17 }
      it_fails { is_expected.to be >= 19 }
      # it { is_expected.to be < 'a' } # Removed because Crystal doesn't support Int32#<(Char)
    end

    describe 'a' do
      it { is_expected.to be < 'b' }

      # deliberate failures
      # it { is_expected.to be < 18 } # Removed because Crystal doesn't support Char#<(Int32)
    end
  end

  context "string operator matchers" do
    describe "Strawberry" do
      it { is_expected.to be < "Tomato" }
      it { is_expected.to be > "Apple" }
      it { is_expected.to be <= "Turnip" }
      it { is_expected.to be >= "Banana" }

      # deliberate failures
      it_fails { is_expected.to be < "Cranberry" }
      it_fails { is_expected.to be > "Zuchini" }
      it_fails { is_expected.to be <= "Potato" }
      it_fails { is_expected.to be >= "Tomato" }
    end
  end
end
