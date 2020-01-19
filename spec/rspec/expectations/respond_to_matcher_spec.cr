require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/respond-to-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`respond_to` matcher" do
  context "basic usage" do
    describe "a string" do
      it { is_expected.to respond_to(:size) } # It's size in Crystal, not length.
      it { is_expected.to respond_to(:hash, :class, :to_s) }
      it { is_expected.not_to respond_to(:to_model) }
      it { is_expected.not_to respond_to(:compact, :flatten) }

      # deliberate failures
      it_fails { is_expected.to respond_to(:to_model) }
      it_fails { is_expected.to respond_to(:compact, :flatten) }
      it_fails { is_expected.not_to respond_to(:size) }
      it_fails { is_expected.not_to respond_to(:hash, :class, :to_s) }

      # mixed examples--String responds to :length but not :flatten
      # both specs should fail
      it_fails { is_expected.to respond_to(:size, :flatten) }
      it_fails { is_expected.not_to respond_to(:size, :flatten) }
    end
  end

  # Spectator doesn't support argument matching with respond_to.
end
