require "./spec_helper"

def new_successful_result(
  example : Spectator::Example? = nil,
  elapsed : Time::Span? = nil,
  expectations : Spectator::Expectations::ExampleExpectations? = nil
)
  Spectator::SuccessfulResult.new(
    example || PassingExample.create,
    elapsed || Time::Span.zero,
    expectations || Spectator::Expectations::ExampleExpectations.new(generate_expectations(1, 0)[:expectations])
  )
end

describe Spectator::SuccessfulResult do
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
      expectations = Spectator::Expectations::ExampleExpectations.new(generate_expectations(5, 0)[:expectations])
      result = new_successful_result(expectations: expectations)
      result.expectations.should eq(expectations)
    end
  end
end
