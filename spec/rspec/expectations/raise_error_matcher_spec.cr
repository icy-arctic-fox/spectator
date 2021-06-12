require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/raise-error-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`raise_error` matcher" do
  context "expect any error" do
    # This example originally calls a non-existent method.
    # That isn't allowed in Crystal.
    # The example has been changed to just raise a runtime error.
    describe "dividing by zero" do
      it "raises" do
        expect { 42 // 0 }.to raise_error
      end
    end
  end

  context "expect specific error" do
    # Again, can't even compile if a method doesn't exist.
    # So using a different exception here.
    describe "dividing by zero" do
      it "raises" do
        expect { 42 // 0 }.to raise_error(DivisionByZeroError)
      end
    end
  end

  # The following examples are changed slightly.
  # `raise Type.new(message)` is the syntax in Crystal,
  # whereas it is `raise Type, message` in Ruby.
  # Additionally, `StandardError` doesn't exist in Crystal,
  # so `Exception` is used instead.
  context "match message with a string" do
    describe "matching error message with string" do
      it "matches the error message" do
        expect { raise Exception.new("this message exactly") }
          .to raise_error("this message exactly")
      end
    end
  end

  context "match message with a regexp" do
    describe "matching error message with regex" do
      it "matches the error message" do
        expect { raise Exception.new("my message") }
          .to raise_error(/my mess/)
      end
    end
  end

  context "matching message with `with_message`" do
    describe "matching error message with regex" do
      it "matches the error message" do
        expect { raise Exception.new("my message") }
          .to raise_error.with_message(/my mess/)
      end
    end
  end

  context "match class + message with string" do
    describe "matching error message with string" do
      it "matches the error message" do
        expect { raise Exception.new("this message exactly") }
          .to raise_error(Exception, "this message exactly")
      end
    end
  end

  context "match class + message with regexp" do
    describe "matching error message with regex" do
      it "matches the error message" do
        expect { raise Exception.new("my message") }
          .to raise_error(Exception, /my mess/)
      end
    end
  end

  context "set expectations on error object passed to block" do
    skip "raises DivisionByZeroError", reason: "Support passing a block to `raise_error` matcher." do
      expect { 42 // 0 }.to raise_error do |error|
        expect(error).to be_a(DivisionByZeroError)
      end
    end
  end

  context "expect no error at all" do
    describe "#to_s" do
      it "does not raise" do
        expect { 42.to_s }.not_to raise_error
      end
    end
  end
end
