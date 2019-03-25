require "./spec_helper"

describe Spectator::NullExampleFilter do
  describe "#includes?" do
    it "returns true" do
      example = PassingExample.create
      filter = Spectator::NullExampleFilter.new
      filter.includes?(example).should be_true
    end
  end
end
