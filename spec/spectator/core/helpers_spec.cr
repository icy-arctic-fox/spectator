require "../../spec_helper"

{% for suffix in %w[A B C] %}
private class {{("HelperObject" + suffix).id}}
  class_getter instances = [] of self

  def initialize
    @@instances << self
  end
end
{% end %}

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

    let instance = HelperObjectA.new

    it "sets the value before each example" do |example|
      # There should be an instance created for each *executed* example in the group plus the initial one.
      example_count = count_executed_examples(example.group)
      expect(HelperObjectA.instances.size).to eq(example_count + 1)
    end

    it "does not reuse the instance" do
      expect(HelperObjectA.instances).to all_be_unique
    end

    it "retains the type and isn't nullable" do
      expect(x).to have_type(Int32)
      # The type becomes a union due to the different type from the nested context.
      expect(instance).to have_type(HelperObjectA | String)
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
        expect(instance).to have_type(String | HelperObjectA)
      end
    end
  end

  describe "#let?" do
    let? x = 42

    it "sets the value" do
      expect(x).to eq(42)
    end

    let? instance = HelperObjectB.new

    it "sets the value before each example" do |example|
      # There should be an instance created for each *executed* example.
      example_count = count_executed_examples(example.group)
      expect(HelperObjectB.instances.size).to eq(example_count)
    end

    it "does not reuse the instance" do
      expect(HelperObjectB.instances).to all_be_unique
    end

    it "retains the type and is nullable" do
      expect(x).to have_type(Int32?)
      # The type becomes a union due to the different type from the nested context.
      expect(instance).to have_type(HelperObjectB | String?)
    end

    let? y = x.try &.+ 1

    it "can depend on other values" do
      expect(y).to eq(43)
    end

    context "can override the value in a nested context" do
      let? x = 99

      it "sets the value" do
        expect(x).to eq(99)
      end

      let? instance = "foo"

      it "changes the type" do
        expect(instance).to have_type(String | HelperObjectB?)
      end
    end
  end

  describe "#let!" do
    let! x = 42

    it "sets the value" do
      expect(x).to eq(42)
    end

    let! instance = HelperObjectC.new

    it "sets the value before each example" do |example|
      # There should be an instance created for each *executed* example in the group.
      example_count = count_executed_examples(example.group)
      expect(HelperObjectC.instances.size).to eq(example_count)
    end

    it "does not reuse the instance" do
      expect(HelperObjectC.instances).to all_be_unique
    end

    it "retains the type and isn't nullable" do
      expect(x).to have_type(Int32)
      # The type becomes a union due to the different type from the nested context.
      expect(instance).to have_type(HelperObjectC | String)
    end

    let! y = x + 1

    it "can depend on other values" do
      expect(y).to eq(43)
    end

    context "can override the value in a nested context" do
      let! x = 99

      it "sets the value" do
        expect(x).to eq(99)
      end

      let! instance = "foo"

      it "changes the type" do
        expect(instance).to have_type(String | HelperObjectC)
      end
    end
  end
end
