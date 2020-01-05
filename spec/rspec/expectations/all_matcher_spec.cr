require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/all-matcher
# and modified to fit Spectator and Crystal.
Spectator.describe "`all` matcher" do
  context "array usage" do
    describe [1, 3, 5] do
      it { is_expected.to all(be_odd) }
      it { is_expected.to all(be_an(Int32)) } # Changed to Int32 to satisfy compiler.
      it { is_expected.to all(be < 10) }

      # deliberate failures
      # TODO: Add support for expected failures.
      xit { is_expected.to all(be_even) }
      xit { is_expected.to all(be_a(String)) }
      xit { is_expected.to all(be > 2) }
    end
  end

  context "compound matcher usage" do
    # Changed `include` to `contain` to match our own.
    # `include` is a keyword and can't be used as a method name in Crystal.

    # TODO: Add support for compound matchers.
    describe ["anything", "everything", "something"] do
      xit { is_expected.to all(be_a(String)) }    # .and contain("thing") ) }
      xit { is_expected.to all(be_a(String)) }    # .and end_with("g") ) }
      xit { is_expected.to all(start_with("s")) } # .or contain("y") ) }

      # deliberate failures
      # TODO: Add support for expected failures.
      # TODO: Add support for compound matchers.
      xit { is_expected.to all(contain("foo")) }  # .and contain("bar") ) }
      xit { is_expected.to all(be_a(String)) }    # .and start_with("a") ) }
      xit { is_expected.to all(start_with("a")) } # .or contain("z") ) }
    end
  end
end
