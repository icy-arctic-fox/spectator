require "./spec_helper"

describe Spectator::CompositeExampleFilter do
  describe "#includes?" do
    context "with a matching filter" do
      it "is true" do
        example = PassingExample.create
        filters = [Spectator::NullExampleFilter.new.as(Spectator::ExampleFilter)]
        filter = Spectator::CompositeExampleFilter.new(filters)
        filter.includes?(example).should be_true
      end
    end

    context "with a non-matching filter" do
      it "is false" do
        example = PassingExample.create
        source = Spectator::Source.new(__FILE__, __LINE__)
        filters = [Spectator::SourceExampleFilter.new(source).as(Spectator::ExampleFilter)]
        filter = Spectator::CompositeExampleFilter.new(filters)
        filter.includes?(example).should be_false
      end
    end

    context "with no filters" do
      it "is false" do
        example = PassingExample.create
        filters = [] of Spectator::ExampleFilter
        filter = Spectator::CompositeExampleFilter.new(filters)
        filter.includes?(example).should be_false
      end
    end
  end
end
