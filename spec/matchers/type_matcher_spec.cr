require "../spec_helper"

Spectator.describe Spectator::Matchers::TypeMatcher do
  context String do # Sets `described_class` to String
    def other_type
      Int32
    end

    describe "#|" do
      it "works on sets" do
        super_set = (described_class | other_type)

        expect(42).to be_kind_of(super_set)
        expect("foo").to be_a(super_set)
      end
    end

    it "works on described_class" do
      expect("foo").to be_a_kind_of(described_class)
    end

    it "works on plain types" do
      expect(42).to be_a(Int32)
    end
  end
end
