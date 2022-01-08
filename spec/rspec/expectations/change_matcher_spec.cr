require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/change-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`change` matcher" do
  # Modified this example type to work in Crystal.
  module Counter
    extend self

    @@count = 0

    def increment
      @@count += 1
    end

    def count
      @@count
    end
  end

  context "expect change" do
    describe "Counter#increment" do # TODO: Allow multiple arguments to context/describe.
      it "should increment the count" do
        expect { Counter.increment }.to change { Counter.count }.from(0).to(1)
      end

      # deliberate failure
      it_fails "should increment the count by 2" do
        expect { Counter.increment }.to change { Counter.count }.by(2)
      end
    end
  end

  context "expect no change" do
    describe "Counter#increment" do # TODO: Allow multiple arguments to context/describe.
      # deliberate failures
      it_fails "should not increment the count by 1 (using not_to)" do
        expect { Counter.increment }.not_to change { Counter.count }
      end

      it_fails "should not increment the count by 1 (using to_not)" do
        expect { Counter.increment }.to_not change { Counter.count }
      end
    end
  end
end
