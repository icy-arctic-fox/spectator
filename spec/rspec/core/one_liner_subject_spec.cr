require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-core/v/3-8/docs/subject/one-liner-syntax
# and modified to fit Spectator and Crystal.
Spectator.describe "One-liner syntax" do
  context "Implicit subject" do
    describe Array(Int32) do
      # Rather than:
      # it "should be empty" do
      #   subject.should be_empty
      # end

      it { should be_empty }
      # or
      it { is_expected.to be_empty }
    end
  end

  context "Explicit subject" do
    describe Array(Int32) do
      describe "with 3 items" do
        subject { [1, 2, 3] }

        it { should_not be_empty }
        # or
        it { is_expected.not_to be_empty }
      end
    end
  end
end
