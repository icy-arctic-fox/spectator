require "./spec_helper"

class ConcretePendingExample < Spectator::PendingExample
  def what
    "PENDING_TEST_EXAMPLE"
  end

  def source
    ::Spectator::Source.new(__FILE__, __LINE__)
  end

  def symbolic?
    false
  end

  def instance
    nil
  end
end

def new_pending_example(group : Spectator::ExampleGroup? = nil)
  ConcretePendingExample.new(group || new_root_group, Spectator::Internals::SampleValues.empty)
end

def new_pending_example_with_hooks(hooks)
  group = new_root_group(hooks)
  new_pending_example(group)
end

describe Spectator::PendingExample do
  describe "#run" do
    it "returns a pending result" do
      new_pending_example.run.should be_a(Spectator::PendingResult)
    end

    it "doesn't run before_all hooks" do
      called = false
      hooks = new_hooks(before_all: ->{ called = true; nil })
      example = new_pending_example_with_hooks(hooks)
      Spectator::Internals::Harness.run(example)
      called.should be_false
    end

    it "doesn't run before_each hooks" do
      called = false
      hooks = new_hooks(before_each: ->{ called = true; nil })
      example = new_pending_example_with_hooks(hooks)
      Spectator::Internals::Harness.run(example)
      called.should be_false
    end

    it "doesn't run after_all hooks" do
      called = false
      hooks = new_hooks(after_all: ->{ called = true; nil })
      example = new_pending_example_with_hooks(hooks)
      Spectator::Internals::Harness.run(example)
      called.should be_false
    end

    it "doesn't run after_each hooks" do
      called = false
      hooks = new_hooks(after_each: ->{ called = true; nil })
      example = new_pending_example_with_hooks(hooks)
      Spectator::Internals::Harness.run(example)
      called.should be_false
    end

    it "doesn't run around_each hooks" do
      called = false
      hooks = new_hooks(around_each: ->(proc : ->) { called = true; proc.call })
      example = new_pending_example_with_hooks(hooks)
      Spectator::Internals::Harness.run(example)
      called.should be_false
    end
  end

  describe "#finished?" do
    it "is initially false" do
      new_pending_example.finished?.should be_false
    end

    it "is true after #run is called" do
      example = new_pending_example
      Spectator::Internals::Harness.run(example)
      example.finished?.should be_true
    end
  end

  describe "#group" do
    it "is the expected value" do
      group = new_root_group
      example = new_pending_example(group)
      example.group.should eq(group)
    end
  end

  describe "#example_count" do
    it "is one" do
      new_pending_example.example_count.should eq(1)
    end
  end

  describe "#[]" do
    it "returns self" do
      example = new_pending_example
      example[0].should eq(example)
    end
  end

  describe "#to_s" do
    it "contains #what" do
      example = new_pending_example
      example.to_s.should contain(example.what)
    end

    it "contains the group's #what" do
      group = new_nested_group
      example = new_pending_example(group)
      example.to_s.should contain(group.what.to_s)
    end
  end

  describe "#===" do
    context "with a matching Regex" do
      it "is true" do
        example = new_pending_example
        regex = Regex.new(Regex.escape(example.what))
        (example === regex).should be_true
      end
    end

    context "with a non-matching Regex" do
      it "is false" do
        example = new_pending_example
        regex = /BOGUS/
        (example === regex).should be_false
      end
    end

    context "with a String equal to the name" do
      it "is true" do
        example = new_pending_example
        (example === example.to_s).should be_true
      end
    end

    context "with a String different than the name" do
      it "is false" do
        example = new_pending_example
        (example === "BOGUS").should be_false
      end
    end

    context "with a matching source location" do
      it "is true" do
        example = new_pending_example
        (example === example.source).should be_true
      end
    end

    context "with a non-matching source location" do
      it "is false" do
        example = new_pending_example
        source = Spectator::Source.new(__FILE__, __LINE__)
        (example === source).should be_false
      end
    end

    context "with a matching source line" do
      it "is true" do
        example = new_pending_example
        (example === example.source.line).should be_true
      end
    end

    context "with a non-matching source line" do
      it "is false" do
        example = new_pending_example
        line = example.source.line + 5
        (example === line).should be_false
      end
    end
  end
end
