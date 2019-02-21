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
    context "without a block" do
      it "invokes #error on an instance" do
        spy = ResultCallSpy.new
        new_errored_result.call(spy)
        spy.error?.should be_true
      end

      it "returns the value of #failure" do
        result = new_errored_result
        returned = result.call(ResultCallSpy.new)
        returned.should eq(:error)
      end
    end

    context "with a block" do
      it "invokes #error on an instance" do
        spy = ResultCallSpy.new
        new_errored_result.call(spy) { nil }
        spy.error?.should be_true
      end

      it "yields itself" do
        result = new_errored_result
        value = nil.as(Spectator::Result?)
        result.call(ResultCallSpy.new) { |r| value = r }
        value.should eq(result)
      end

      it "returns the value of #failure" do
        result = new_errored_result
        value = 42
        returned = result.call(ResultCallSpy.new) { value }
        returned.should eq(value)
      end
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
