require "../spec_helper"

describe Spectator::DSL::ExampleFactory do
  describe "#build" do
    it "creates an example of the correct type" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      example = factory.build(group, Spectator::Internals::SampleValues.empty)
      example.should be_a(SpyExample)
    end

    it "passes along the group" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      example = factory.build(group, Spectator::Internals::SampleValues.empty)
      example.group.should eq(group)
    end

    it "passes along the sample values" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      values = Spectator::Internals::SampleValues.empty.add(:foo, "foo", 12345)
      example = factory.build(group, values)
      example.as(SpyExample).sample_values.should eq(values)
    end
  end
end
