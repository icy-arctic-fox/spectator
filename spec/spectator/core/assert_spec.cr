require "../../spec_helper"

Spectator.describe "Assertions" do
  describe "#assert" do
    it "raises an AssertionFailed error if the value is false" do
      expect { assert false }.to raise_error(Spectator::AssertionFailed)
    end

    it "does not raise an error if the value is true" do
      expect { assert true }.to_not raise_error
    end

    it "stores the location of the assertion" do
      error = expect { assert false }.to raise_error(Spectator::AssertionFailed)
      expect(error).to have_location(Spectator::Core::Location.here(-1))
    end
  end

  describe "#fail" do
    it "raises an AssertionFailed error" do
      expect { fail }.to raise_error(Spectator::AssertionFailed)
    end

    it "raises an AssertionFailed error with a message" do
      expect { fail "foo" }.to raise_error(Spectator::AssertionFailed, "foo")
    end

    it "stores the location of the assertion" do
      error = expect { fail }.to raise_error(Spectator::AssertionFailed)
      expect(error).to have_location(Spectator::Core::Location.here(-1))
    end
  end

  describe "#skip" do
    it "raises an ExampleSkipped error" do
      expect { skip }.to raise_error(Spectator::ExampleSkipped)
    end

    it "raises an ExampleSkipped error with a message" do
      expect { skip "foo" }.to raise_error(Spectator::ExampleSkipped, "foo")
    end

    it "stores the location of the assertion" do
      error = expect { skip }.to raise_error(Spectator::ExampleSkipped)
      expect(error).to have_location(Spectator::Core::Location.here(-1))
    end
  end
end
