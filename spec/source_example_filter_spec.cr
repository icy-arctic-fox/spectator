require "./spec_helper"

describe Spectator::SourceExampleFilter do
  describe "#includes?" do
    context "with a matching example" do
      it "is true" do
        example = PassingExample.create
        filter = Spectator::SourceExampleFilter.new(example.source)
        filter.includes?(example).should be_true
      end
    end

    context "with a non-matching example" do
      it "is false" do
        example = PassingExample.create
        source = Spectator::Source.new(__FILE__, __LINE__)
        filter = Spectator::SourceExampleFilter.new(source)
        filter.includes?(example).should be_false
      end
    end
  end
end
