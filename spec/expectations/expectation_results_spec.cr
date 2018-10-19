require "../spec_helper"

describe Spectator::Expectations::ExpectationResults do
  describe "#each" do
    it "yields all results" do
      fail "Test not implemented"
    end
  end

  describe "#successes" do
    it "returns only successful results" do
      fail "Test not implemented"
    end

    context "with all successful results" do
      it "returns all results" do
        fail "Test not implemented"
      end
    end

    context "with all failure results" do
      it "returns an empty collection" do
        fail "Test not implemented"
      end
    end
  end

  describe "#each_success" do
    it "yields only successful results" do
      fail "Test not implemented"
    end

    context "with all successful results" do
      it "yields all results" do
        fail "Test not implemented"
      end
    end

    context "with all failure results" do
      it "yields nothing" do
        fail "Test not implemented"
      end
    end
  end

  describe "#failures" do
    it "returns only failed results" do
      fail "Test not implemented"
    end

    context "with all successful results" do
      it "returns an empty collection" do
        fail "Test not implemented"
      end
    end

    context "with all failure results" do
      it "returns all results" do
        fail "Test not implemented"
      end
    end
  end

  describe "#each_failure" do
    it "yields only failed results" do
      fail "Test not implemented"
    end

    context "with all successful results" do
      it "yields nothing" do
        fail "Test not implemented"
      end
    end

    context "with one failure result" do
      it "yields the one failed result" do
        fail "Test not implemented"
      end
    end
  end

  describe "#successful?" do
    context "with all successful results" do
      it "is true" do
        fail "Test not implemented"
      end
    end

    context "with one failure result" do
      it "is false" do
        fail "Test not implemented"
      end
    end

    context "with one successful result" do
      it "is false" do
        fail "Test not implemented"
      end
    end

    context "with all failure results" do
      it "is false" do
        fail "Test not implemented"
      end
    end
  end

  describe "#failed?" do
    context "with all successful results" do
      it "is false" do
        fail "Test not implemented"
      end
    end

    context "with one failure result" do
      it "is true" do
        fail "Test not implemented"
      end
    end

    context "with one successful result" do
      it "is true" do
        fail "Test not implemented"
      end
    end

    context "with all failure results" do
      it "is true" do
        fail "Test not implemented"
      end
    end
  end
end
