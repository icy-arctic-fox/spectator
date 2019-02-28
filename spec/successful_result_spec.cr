require "./spec_helper"

def new_successful_result(
  example : Spectator::Example? = nil,
  elapsed : Time::Span? = nil,
  expectations : Spectator::Expectations::ExampleExpectations? = nil
)
  Spectator::SuccessfulResult.new(
    example || PassingExample.create,
    elapsed || Time::Span.zero,
    expectations || Spectator::Expectations::ExampleExpectations.new([new_satisfied_expectation])
  )
end

describe Spectator::SuccessfulResult do
  describe "#call" do
    context "without a block" do
      it "invokes #success on an instance" do
        spy = ResultCallSpy.new
        new_successful_result.call(spy)
        spy.success?.should be_true
      end

      it "returns the value of #success" do
        result = new_successful_result
        returned = result.call(ResultCallSpy.new)
        returned.should eq(:success)
      end
    end

    context "with a block" do
      it "invokes #success on an instance" do
        spy = ResultCallSpy.new
        new_successful_result.call(spy) { nil }
        spy.success?.should be_true
      end

      it "yields itself" do
        result = new_successful_result
        value = nil.as(Spectator::Result?)
        result.call(ResultCallSpy.new) { |r| value = r }
        value.should eq(result)
      end

      it "returns the value of #success" do
        result = new_successful_result
        value = 42
        returned = result.call(ResultCallSpy.new) { value }
        returned.should eq(value)
      end
    end
  end

  describe "#example" do
    it "is the expected value" do
      example = PassingExample.create
      result = new_successful_result(example: example)
      result.example.should eq(example)
    end
  end

  describe "#elapsed" do
    it "is the expected value" do
      elapsed = Time::Span.new(10, 10, 10)
      result = new_successful_result(elapsed: elapsed)
      result.elapsed.should eq(elapsed)
    end
  end

  describe "#expectations" do
    it "is the expected value" do
      expectations = Spectator::Expectations::ExampleExpectations.new(create_expectations(5, 0))
      result = new_successful_result(expectations: expectations)
      result.expectations.should eq(expectations)
    end
  end
end
