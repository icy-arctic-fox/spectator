require "./spec_helper"

def new_pending_result(example : Spectator::Example? = nil)
  Spectator::PendingResult.new(example || FailingExample.create)
end

describe Spectator::PendingResult do
  describe "#example" do
    it "is the expected value" do
      example = PassingExample.create
      result = new_pending_result(example: example)
      result.example.should eq(example)
    end
  end
end
