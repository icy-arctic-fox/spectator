require "./spec_helper"

describe Spectator::NameExampleFilter do
  describe "#includes?" do
    context "with a matching example" do
      it "is true" do
        example = PassingExample.create
        filter = Spectator::NameExampleFilter.new(example.to_s)
        filter.includes?(example).should be_true
      end
    end

    context "with a non-matching example" do
      it "is false" do
        example = PassingExample.create
        filter = Spectator::NameExampleFilter.new("BOGUS")
        filter.includes?(example).should be_false
      end
    end
  end
end
