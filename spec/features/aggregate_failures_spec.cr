require "../spec_helper"

Spectator.describe Spectator, :smoke do
  describe "aggregate_failures" do
    it "captures multiple failed expectations" do
      expect do
        aggregate_failures do
          expect(true).to be_false
          expect(false).to be_true
        end
      end.to raise_error(Spectator::MultipleExpectationsFailed, /2 failures/)
    end

    it "raises normally for one failed expectation" do
      expect do
        aggregate_failures do
          expect(true).to be_false
          expect(true).to be_true
        end
      end.to raise_error(Spectator::ExpectationFailed)
    end

    it "doesn't raise when there are no failed expectations" do
      expect do
        aggregate_failures do
          expect(false).to be_false
          expect(true).to be_true
        end
      end.to_not raise_error(Spectator::ExpectationFailed)
    end

    it "supports naming the block" do
      expect do
        aggregate_failures "contradiction" do
          expect(true).to be_false
          expect(false).to be_true
        end
      end.to raise_error(Spectator::MultipleExpectationsFailed, /contradiction/)
    end
  end
end
