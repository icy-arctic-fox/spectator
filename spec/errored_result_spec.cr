require "./spec_helper"

def new_errored_result(
  example : Spectator::Example? = nil,
  elapsed : Time::Span? = nil,
  expectations : Spectator::Expectations::ExampleExpectations? = nil,
  error : Exception? = nil
)
  Spectator::ErroredResult.new(
    example || FailingExample.create,
    elapsed || Time::Span.zero,
    expectations || Spectator::Expectations::ExampleExpectations.new(generate_expectations(0, 1)[:expectations]),
    error || Exception.new("foobar")
  )
end

describe Spectator::ErroredResult do
  describe "#call" do
    it "invokes #error on an instance" do
      spy = ResultCallSpy.new
      new_errored_result.call(spy)
      spy.error?.should be_truthy
    end

    it "passes itself" do
      spy = ResultCallSpy.new
      result = new_errored_result
      result.call(spy)
      spy.error.should eq(result)
    end
  end

  describe "#example" do
    it "is the expected value" do
      example = FailingExample.create
      result = new_errored_result(example: example)
      result.example.should eq(example)
    end
  end

  describe "#elapsed" do
    it "is the expected value" do
      elapsed = Time::Span.new(10, 10, 10)
      result = new_errored_result(elapsed: elapsed)
      result.elapsed.should eq(elapsed)
    end
  end

  describe "#expectations" do
    it "is the expected value" do
      expectations = Spectator::Expectations::ExampleExpectations.new(generate_expectations(5, 1)[:expectations])
      result = new_errored_result(expectations: expectations)
      result.expectations.should eq(expectations)
    end
  end

  describe "#error" do
    it "is the expected value" do
      error = IO::Error.new("oops")
      result = new_errored_result(error: error)
      result.error.should eq(error)
    end
  end
end
