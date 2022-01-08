require "../../spec_helper"

Spectator.describe "`be_between` matcher" do
  context "basic usage" do
    describe 7 do
      it { is_expected.to be_between(1, 10) }
      it { is_expected.to be_between(0.2, 27.1) }
      it { is_expected.not_to be_between(1.5, 4) }
      it { is_expected.not_to be_between(8, 9) }

      # boundaries check
      it { is_expected.to be_between(0, 7) }
      it { is_expected.to be_between(7, 10) }
      it { is_expected.not_to(be_between(0, 7).exclusive) }
    end
  end
end
