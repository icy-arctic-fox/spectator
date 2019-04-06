require "./spec_helper"

describe Spectator::TestSuite do
  describe "#each" do
    it "yields each example" do
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      group.children = Array.new(5) do
        PassingExample.new(group, Spectator::Internals::SampleValues.empty).as(Spectator::ExampleComponent)
      end
      test_suite = Spectator::TestSuite.new(group, Spectator::NullExampleFilter.new)
      examples = [] of Spectator::Example
      test_suite.each do |example|
        examples << example
      end
      examples.should eq(group.children)
    end

    it "skips examples not in the filter" do
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      group.children = Array.new(5) do
        PassingExample.new(group, Spectator::Internals::SampleValues.empty).as(Spectator::ExampleComponent)
      end
      test_suite = Spectator::TestSuite.new(group, Spectator::CompositeExampleFilter.new([] of Spectator::ExampleFilter))
      examples = [] of Spectator::Example
      test_suite.each do |example|
        examples << example
      end
      examples.should be_empty
    end
  end
end
