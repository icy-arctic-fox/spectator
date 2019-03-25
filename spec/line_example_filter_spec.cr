require "./spec_helper"

describe Spectator::LineExampleFilter do
  describe "#includes?" do
    context "with a matching example" do
      it "is true" do
        example = PassingExample.create
        filter = Spectator::LineExampleFilter.new(example.source.line)
        filter.includes?(example).should be_true
      end
    end

    context "with a non-matching example" do
      it "is false" do
        example = PassingExample.create
        filter = Spectator::LineExampleFilter.new(example.source.line + 5)
        filter.includes?(example).should be_false
      end
    end
  end
end
