require "../../spec_helper"

private class HelperObject
  class_getter instances = [] of self

  def initialize
    @@instances << self
  end
end

private def count_executed_examples(group)
  count = 0
  group.each do |item|
    next unless example = item.as?(Spectator::Core::Example)
    count += 1 if example.run?
  end
  count
end

Spectator.describe Spectator::Core::Helpers do
  describe "#let" do
    let x = 42

    it "sets the value" do
      expect(x).to eq(42)
    end

    let instance = HelperObject.new

    it "sets the value before each example" do |example|
      # There should be an instance created for each *executed* example in the group.
      example_count = count_executed_examples(example.group)
      expect(HelperObject.instances.size).to eq(example_count)
    end

    it "does not reuse the instance" do
      expect(HelperObject.instances).to all_be_unique
    end

    it "retains the type and isn't nullable" do
      expect(x).to have_type(Int32)
      # The type becomes a union due to the different type from the nested context.
      expect(instance).to have_type(HelperObject | String)
    end

    let y = x + 1

    it "can depend on other values" do
      expect(y).to eq(43)
    end

    context "can override the value in a nested context" do
      let x = 99

      it "sets the value" do
        expect(x).to eq(99)
      end

      let instance = "foo"

      it "changes the type" do
        expect(instance).to have_type(String | HelperObject)
      end
    end
  end
end
