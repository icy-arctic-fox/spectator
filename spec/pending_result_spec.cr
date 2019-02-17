require "./spec_helper"

def new_pending_result(example : Spectator::Example? = nil)
  Spectator::PendingResult.new(example || FailingExample.create)
end

describe Spectator::PendingResult do
  describe "#call" do
    it "invokes #pending on an instance" do
      spy = ResultCallSpy.new
      new_pending_result.call(spy)
      spy.pending?.should be_truthy
    end

    it "passes itself" do
      spy = ResultCallSpy.new
      result = new_pending_result
      result.call(spy)
      spy.pending.should eq(result)
    end
  end

  describe "#example" do
    it "is the expected value" do
      example = PassingExample.create
      result = new_pending_result(example: example)
      result.example.should eq(example)
    end
  end
end
