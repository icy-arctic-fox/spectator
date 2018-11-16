require "./spec_helper"

def new_pending_result(example : Spectator::Example? = nil)
  Spectator::PendingResult.new(example || FailingExample.create)
end

describe Spectator::PendingResult do
  describe "#pending?" do
    it "is true" do
      new_pending_result.pending?.should be_true
    end
  end

  describe "#passed?" do
    it "is false" do
      new_pending_result.passed?.should be_false
    end
  end

  describe "#failed?" do
    it "is false" do
      new_pending_result.failed?.should be_false
    end
  end

  describe "#errored?" do
    it "is false" do
      new_pending_result.errored?.should be_false
    end
  end

  describe "#example" do
    it "is the expected value" do
      example = PassingExample.create
      result = new_pending_result(example: example)
      result.example.should eq(example)
    end
  end

  describe "#elapsed" do
    it "is zero" do
      new_pending_result.elapsed.should eq(Time::Span.zero)
    end
  end
end
