require "../spec_helper"

Spectator.describe String do
  subject { "foo" }

  describe "#==" do
    context "with the same value" do
      let(value) { subject.dup }

      it "is true" do
        is_expected.to eq(value)
      end
    end

    context "with a different value" do
      let(value) { "bar" }

      it "is false" do
        is_expected.to_not eq(value)
      end
    end
  end
end
