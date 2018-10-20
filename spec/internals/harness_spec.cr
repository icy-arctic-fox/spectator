require "../spec_helper"

describe Spectator::Internals::Harness do
  describe "#run" do
    it "runs an example" do
      run_count = 0
      spy = SpyExample.create do
        run_count += 1
      end
      Spectator::Internals::Harness.run(spy)
      run_count.should eq(1)
    end

    context "with a passing exmaple" do
      it "returns a successful result" do

      end
    end

    context "with a failing example" do
      it "returns a failed result" do

      end
    end
  end

  describe "#current" do
    it "references the current harness" do
      harness = nil.as(Spectator::Internals::Harness?)
      spy = SpyExample.create do
        harness = Spectator::Internals::Harness.current
      end
      Spectator::Internals::Harness.run(spy)
      harness.should be_a(Spectator::Internals::Harness)
    end
  end

  describe "#example" do
    it "references the current example" do
      example = nil.as(Spectator::Example?)
      spy = SpyExample.create do
        example = Spectator::Internals::Harness.current.example
      end
      Spectator::Internals::Harness.run(spy)
      example.should be(spy)
    end
  end

  describe "#report_expectation" do
    context "with a successful result" do
      it "stores the result" do

      end
    end

    context "with a failed result" do
      it "raises an error" do

      end
    end
  end

  describe "#expectation_results" do
    it "contains the reported results" do

    end
  end
end
