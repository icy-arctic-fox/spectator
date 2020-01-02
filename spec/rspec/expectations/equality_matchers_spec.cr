require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/equality-matchers
# and modified to fit Spectator and Crystal.
Spectator.describe "Equality matchers" do
  context "compare using eq (==)" do
    describe "a string" do
      it "is equal to another string of the same value" do
        expect("this string").to eq("this string")
      end

      it "is not equal to another string of a different value" do
        expect("this string").not_to eq("a different string")
      end
    end

    describe "an integer" do
      it "is equal to a float for the same value" do
        expect(5).to eq(5.0)
      end
    end
  end

  context "compare using ==" do
    describe "a string" do
      it "is equal to another string of the same value" do
        expect("this string").to be == "this string"
      end

      it "is not equal to another string of a different value" do
        expect("this string").not_to be == "a different string"
      end
    end

    describe "an integer" do
      it "is equal to a float of the same value" do
        expect(5).to be == 5.0
      end
    end
  end

  # There are no #eql? and #equal? methods in Crystal, so these tests are skipped.

  context "compare using be (same?)" do
    it "is equal to itself" do
      string = "this string"
      expect(string).to be(string)
    end

    it "is not equal to another reference of the same value" do
      # Strings with identical contents are the same reference in Crystal.
      # This test is modified to reflect that.
      # expect("this string").not_to be("this string")
      box1 = Box.new("this string")
      box2 = Box.new("this string")
      expect(box1).not_to be(box2)
    end

    it "is not equal to another string of a different value" do
      expect("this string").not_to be("a different string")
    end
  end
end
