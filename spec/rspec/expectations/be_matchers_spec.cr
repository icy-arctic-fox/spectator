require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/be-matchers
# and modified to fit Spectator and Crystal.
Spectator.describe "`be` matchers" do
  context "be_truthy matcher" do
    specify { expect(true).to be_truthy }
    specify { expect(7).to be_truthy }
    specify { expect("foo").to be_truthy }
    specify { expect(nil).not_to be_truthy }
    specify { expect(false).not_to be_truthy }

    # deliberate failures
    specify_fails { expect(true).not_to be_truthy }
    specify_fails { expect(7).not_to be_truthy }
    specify_fails { expect("foo").not_to be_truthy }
    specify_fails { expect(nil).to be_truthy }
    specify_fails { expect(false).to be_truthy }
  end

  context "be_falsey matcher" do
    specify { expect(nil).to be_falsey }
    specify { expect(false).to be_falsey }
    specify { expect(true).not_to be_falsey }
    specify { expect(7).not_to be_falsey }
    specify { expect("foo").not_to be_falsey }

    # deliberate failures
    specify_fails { expect(nil).not_to be_falsey }
    specify_fails { expect(false).not_to be_falsey }
    specify_fails { expect(true).to be_falsey }
    specify_fails { expect(7).to be_falsey }
    specify_fails { expect("foo").to be_falsey }
  end

  context "be_nil matcher" do
    specify { expect(nil).to be_nil }
    specify { expect(false).not_to be_nil }
    specify { expect(true).not_to be_nil }
    specify { expect(7).not_to be_nil }
    specify { expect("foo").not_to be_nil }

    # deliberate failures
    specify_fails { expect(nil).not_to be_nil }
    specify_fails { expect(false).to be_nil }
    specify_fails { expect(true).to be_nil }
    specify_fails { expect(7).to be_nil }
    specify_fails { expect("foo").to be_nil }
  end

  context "be matcher" do
    specify { expect(true).to be }
    specify { expect(7).to be }
    specify { expect("foo").to be }
    specify { expect(nil).not_to be }
    specify { expect(false).not_to be }

    # deliberate failures
    specify_fails { expect(true).not_to be }
    specify_fails { expect(7).not_to be }
    specify_fails { expect("foo").not_to be }
    specify_fails { expect(nil).to be }
    specify_fails { expect(false).to be }
  end
end
