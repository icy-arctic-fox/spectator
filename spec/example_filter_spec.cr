require "./spec_helper"

def new_filter(criterion)
  criteria = ["BOGUS", -1, criterion, /^$/, Spectator::Source.new(__FILE__, __LINE__)]
  Spectator::ExampleFilter.new(criteria)
end

describe Spectator::ExampleFilter do
  describe "#includes?" do
    context "with a matching Regex" do
      it "is true" do
        example = new_runnable_example
        regex = Regex.new(Regex.escape(example.what))
        filter = new_filter(regex)
        filter.includes?(example).should be_true
      end
    end

    context "with a non-matching Regex" do
      it "is false" do
        example = new_runnable_example
        regex = /BOGUS/
        filter = new_filter(regex)
        filter.includes?(example).should be_false
      end
    end

    context "with a String equal to the name" do
      it "is true" do
        example = new_runnable_example
        filter = new_filter(example.to_s)
        filter.includes?(example).should be_true
      end
    end

    context "with a String different than the name" do
      it "is false" do
        example = new_runnable_example
        filter = new_filter("FAKE")
        filter.includes?(example).should be_false
      end
    end

    context "with a matching source location" do
      it "is true" do
        example = new_runnable_example
        filter = new_filter(example.source)
        filter.includes?(example).should be_true
      end
    end

    context "with a non-matching source location" do
      it "is false" do
        example = new_runnable_example
        source = Spectator::Source.new(__FILE__, __LINE__)
        filter = new_filter(source)
        filter.includes?(example).should be_false
      end
    end

    context "with a matching source line" do
      it "is true" do
        example = new_runnable_example
        filter = new_filter(example.source.line)
        filter.includes?(example).should be_true
      end
    end

    context "with a non-matching source line" do
      it "is false" do
        example = new_runnable_example
        line = example.source.line + 5
        filter = new_filter(line)
        filter.includes?(example).should be_false
      end
    end

    context "with an empty criteria" do
      it "is true" do
        filter = Spectator::ExampleFilter.new
        filter.includes?(new_runnable_example).should be_true
      end
    end
  end
end
