require "./spec_helper"

def new_pending_result(example : Spectator::Example? = nil)
  Spectator::PendingResult.new(example || FailingExample.create)
end

describe Spectator::PendingResult do
  describe "#call" do
    context "without a block" do
      it "invokes #pending on an instance" do
        spy = ResultCallSpy.new
        new_pending_result.call(spy)
        spy.pending?.should be_true
      end

      it "returns the value of #pending" do
        result = new_pending_result
        returned = result.call(ResultCallSpy.new)
        returned.should eq(:pending)
      end
    end

    context "with a block" do
      it "invokes #pending on an instance" do
        spy = ResultCallSpy.new
        new_pending_result.call(spy) { nil }
        spy.pending?.should be_true
      end

      it "yields itself" do
        result = new_pending_result
        value = nil.as(Spectator::Result?)
        result.call(ResultCallSpy.new) { |r| value = r }
        value.should eq(result)
      end

      it "returns the value of #pending" do
        result = new_pending_result
        value = 42
        returned = result.call(ResultCallSpy.new) { value }
        returned.should eq(value)
      end
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
