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
    # TODO: Add support for expected failures.
    pending { expect(true).not_to be_truthy }
    pending { expect(7).not_to be_truthy }
    pending { expect("foo").not_to be_truthy }
    pending { expect(nil).to be_truthy }
    pending { expect(false).to be_truthy }
  end

  context "be_falsey matcher" do
    specify { expect(nil).to be_falsey }
    specify { expect(false).to be_falsey }
    specify { expect(true).not_to be_falsey }
    specify { expect(7).not_to be_falsey }
    specify { expect("foo").not_to be_falsey }

    # deliberate failures
    # TODO: Add support for expected failures.
    pending { expect(nil).not_to be_falsey }
    pending { expect(false).not_to be_falsey }
    pending { expect(true).to be_falsey }
    pending { expect(7).to be_falsey }
    pending { expect("foo").to be_falsey }
  end

  context "be_nil matcher" do
    specify { expect(nil).to be_nil }
    specify { expect(false).not_to be_nil }
    specify { expect(true).not_to be_nil }
    specify { expect(7).not_to be_nil }
    specify { expect("foo").not_to be_nil }

    # deliberate failures
    # TODO: Add support for expected failures.
    pending { expect(nil).not_to be_nil }
    pending { expect(false).to be_nil }
    pending { expect(true).to be_nil }
    pending { expect(7).to be_nil }
    pending { expect("foo").to be_nil }
  end

  context "be matcher" do
    specify { expect(true).to be }
    specify { expect(7).to be }
    specify { expect("foo").to be }
    specify { expect(nil).not_to be }
    specify { expect(false).not_to be }

    # deliberate failures
    # TODO: Add support for expected failures.
    pending { expect(true).not_to be }
    pending { expect(7).not_to be }
    pending { expect("foo").not_to be }
    pending { expect(nil).to be }
    pending { expect(false).to be }
  end
end
