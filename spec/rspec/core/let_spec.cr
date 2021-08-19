require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-core/v/3-8/docs/helper-methods/let-and-let
# and modified to fit Spectator and Crystal.
Spectator.describe "Let and let!" do
  context "Use `let` to define memoized helper method" do
    # Globals aren't supported, use class variables instead.
    @@count = 0

    describe "let" do
      let(:count) { @@count += 1 }

      it "memoizes the value" do
        expect(count).to eq(1)
        expect(count).to eq(1)
      end

      it "is not cached across examples" do
        expect(count).to eq(2)
      end
    end
  end

  context "Use `let!` to define a memoized helper method that is called in a `before` hook" do
    # Globals aren't supported, use class variables instead.
    @@count = 0

    describe "let!" do
      # Use class variable here.
      @@invocation_order = [] of Symbol

      let!(:count) do
        @@invocation_order << :let!
        @@count += 1
      end

      it "calls the helper method in a before hook" do
        @@invocation_order << :example
        expect(@@invocation_order).to eq([:let!, :example])
        expect(count).to eq(1)
      end
    end
  end
end
