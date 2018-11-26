require "./spec_helper"

def new_nested_group(hooks = Spectator::ExampleHooks.empty, parent : Spectator::ExampleGroup? = nil)
  parent ||= Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
  Spectator::NestedExampleGroup.new("what", parent, hooks).tap do |group|
    parent.children = [group.as(Spectator::ExampleComponent)]
    group.children = [] of Spectator::ExampleComponent
  end
end

def nested_group_with_examples(example_count = 5)
  root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
  group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
  root.children = [group.as(Spectator::ExampleComponent)]
  examples = [] of Spectator::Example
  group.children = Array(Spectator::ExampleComponent).new(example_count) do
    PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
      examples << example
    end
  end
  {group, examples}
end

def nested_group_with_sub_groups(sub_group_count = 5, example_count = 5)
  root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
  group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
  root.children = [group.as(Spectator::ExampleComponent)]
  examples = [] of Spectator::Example
  group.children = Array(Spectator::ExampleComponent).new(sub_group_count) do |i|
    Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty).tap do |sub_group|
      sub_group.children = Array(Spectator::ExampleComponent).new(example_count) do |j|
        PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
          examples << example
        end
      end
    end
  end
  {group, examples}
end

def complex_nested_group
  root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
  group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
  root.children = [group.as(Spectator::ExampleComponent)]
  examples = [] of Spectator::Example
  group.children = Array(Spectator::ExampleComponent).new(10) do |i|
    if i % 2 == 0
      PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
        examples << example
      end
    else
      Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty).tap do |sub_group1|
        sub_group1.children = Array(Spectator::ExampleComponent).new(10) do |j|
          if i % 2 == 0
            PassingExample.new(sub_group1, Spectator::Internals::SampleValues.empty).tap do |example|
              examples << example
            end
          else
            Spectator::NestedExampleGroup.new(j.to_s, sub_group1, Spectator::ExampleHooks.empty).tap do |sub_group2|
              sub_group2.children = Array(Spectator::ExampleComponent).new(5) do
                PassingExample.new(sub_group2, Spectator::Internals::SampleValues.empty).tap do |example|
                  examples << example
                end
              end
            end
          end
        end
      end
    end
  end
  {group, examples}
end

describe Spectator::NestedExampleGroup do
  describe "#what" do
    it "is the expected value" do
      what = "foobar"
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new(what, root, Spectator::ExampleHooks.empty)
      group.what.should eq(what)
    end
  end

  describe "#parent" do
    it "is the expected value" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
      group.parent.should eq(root)
    end
  end

  describe "#run_before_all_hooks" do
    it "runs a single hook" do
      called = false
      hooks = new_hooks(before_all: ->{ called = true; nil })
      group = new_nested_group(hooks)
      group.run_before_all_hooks
      called.should be_true
    end

    it "runs multiple hooks" do
      call_count = 0
      hooks = new_hooks(before_all: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_nested_group(hooks)
      group.run_before_all_hooks
      call_count.should eq(6)
    end

    it "runs hooks in the correct order" do
      calls = [] of Symbol
      hooks = new_hooks(before_all: [
        ->{ calls << :a; nil },
        ->{ calls << :b; nil },
        ->{ calls << :c; nil },
      ])
      group = new_nested_group(hooks)
      group.run_before_all_hooks
      calls.should eq(%i[a b c])
    end

    it "runs the parent hooks" do
      called = false
      hooks = new_hooks(before_all: ->{ called = true; nil })
      root = Spectator::RootExampleGroup.new(hooks)
      group = new_nested_group(parent: root)
      group.run_before_all_hooks
      called.should be_true
    end

    it "runs the parent hooks first" do
      calls = [] of Symbol
      root_hooks = new_hooks(before_all: ->{ calls << :a; nil })
      group_hooks = new_hooks(before_all: ->{ calls << :b; nil })
      root = Spectator::RootExampleGroup.new(root_hooks)
      group = new_nested_group(group_hooks, root)
      group.run_before_all_hooks
      calls.should eq(%i[a b])
    end

    it "runs the hooks once" do
      call_count = 0
      hooks = new_hooks(before_all: ->{ call_count += 1; nil })
      group = new_nested_group(hooks)
      2.times { group.run_before_all_hooks }
      call_count.should eq(1)
    end
  end

  describe "#run_before_each_hooks" do
    it "runs a single hook" do
      called = false
      hooks = new_hooks(before_each: ->{ called = true; nil })
      group = new_nested_group(hooks)
      group.run_before_each_hooks
      called.should be_true
    end

    it "runs multiple hooks" do
      call_count = 0
      hooks = new_hooks(before_each: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_nested_group(hooks)
      group.run_before_each_hooks
      call_count.should eq(6)
    end

    it "runs hooks in the correct order" do
      calls = [] of Symbol
      hooks = new_hooks(before_each: [
        ->{ calls << :a; nil },
        ->{ calls << :b; nil },
        ->{ calls << :c; nil },
      ])
      group = new_nested_group(hooks)
      group.run_before_each_hooks
      calls.should eq(%i[a b c])
    end

    it "runs the parent hooks" do
      called = false
      hooks = new_hooks(before_each: ->{ called = true; nil })
      root = Spectator::RootExampleGroup.new(hooks)
      group = new_nested_group(parent: root)
      group.run_before_each_hooks
      called.should be_true
    end

    it "runs the parent hooks first" do
      calls = [] of Symbol
      root_hooks = new_hooks(before_each: ->{ calls << :a; nil })
      group_hooks = new_hooks(before_each: ->{ calls << :b; nil })
      root = Spectator::RootExampleGroup.new(root_hooks)
      group = new_nested_group(group_hooks, root)
      group.run_before_each_hooks
      calls.should eq(%i[a b])
    end

    it "runs the hooks multiple times" do
      call_count = 0
      hooks = new_hooks(before_each: ->{ call_count += 1; nil })
      group = new_nested_group(hooks)
      2.times { group.run_before_each_hooks }
      call_count.should eq(2)
    end
  end

  describe "#run_after_all_hooks" do
    # No children are used for most of these examples.
    # That's because `[].all?` is always true.
    # Which means that all examples are considered finished, since there are none.
    it "runs a single hook" do
      called = false
      hooks = new_hooks(after_all: ->{ called = true; nil })
      group = new_nested_group(hooks)
      group.run_after_all_hooks
      called.should be_true
    end

    it "runs multiple hooks" do
      call_count = 0
      hooks = new_hooks(after_all: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_nested_group(hooks)
      group.run_after_all_hooks
      call_count.should eq(6)
    end

    it "runs hooks in the correct order" do
      calls = [] of Symbol
      hooks = new_hooks(after_all: [
        ->{ calls << :a; nil },
        ->{ calls << :b; nil },
        ->{ calls << :c; nil },
      ])
      group = new_nested_group(hooks)
      group.run_after_all_hooks
      calls.should eq(%i[a b c])
    end

    it "runs the parent hooks" do
      called = false
      hooks = new_hooks(after_all: ->{ called = true; nil })
      root = Spectator::RootExampleGroup.new(hooks)
      group = new_nested_group(parent: root)
      group.run_after_all_hooks
      called.should be_true
    end

    it "runs the parent hooks last" do
      calls = [] of Symbol
      root_hooks = new_hooks(after_all: ->{ calls << :a; nil })
      group_hooks = new_hooks(after_all: ->{ calls << :b; nil })
      root = Spectator::RootExampleGroup.new(root_hooks)
      group = new_nested_group(group_hooks, root)
      group.run_after_all_hooks
      calls.should eq(%i[b a])
    end

    it "runs the hooks once" do
      call_count = 0
      hooks = new_hooks(after_all: ->{ call_count += 1; nil })
      group = new_nested_group(hooks)
      2.times { group.run_after_all_hooks }
      call_count.should eq(1)
    end

    context "with no examples finished" do
      it "doesn't run the hooks" do
        called = false
        hooks = new_hooks(after_all: ->{ called = true; nil })
        root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
        group = Spectator::NestedExampleGroup.new("what", root, hooks)
        root.children = [group.as(Spectator::ExampleComponent)]
        group.children = Array(Spectator::ExampleComponent).new(5) do
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        end
        group.run_after_all_hooks
        called.should be_false
      end

      it "doesn't run the parent hooks" do
        called = false
        hooks = new_hooks(after_all: ->{ called = true; nil })
        root = Spectator::RootExampleGroup.new(hooks)
        group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
        root.children = [group.as(Spectator::ExampleComponent)]
        group.children = Array(Spectator::ExampleComponent).new(5) do
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        end
        group.run_after_all_hooks
        called.should be_false
      end
    end

    context "with some examples finished" do
      it "doesn't run the hooks" do
        called = false
        hooks = new_hooks(after_all: ->{ called = true; nil })
        root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
        group = Spectator::NestedExampleGroup.new("what", root, hooks)
        root.children = [group.as(Spectator::ExampleComponent)]
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
            Spectator::Internals::Harness.run(example) if i % 2 == 0
          end
        end
        group.run_after_all_hooks
        called.should be_false
      end

      it "doesn't run the parent hooks" do
        called = false
        hooks = new_hooks(after_all: ->{ called = true; nil })
        root = Spectator::RootExampleGroup.new(hooks)
        group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
        root.children = [group.as(Spectator::ExampleComponent)]
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
            Spectator::Internals::Harness.run(example) if i % 2 == 0
          end
        end
        group.run_after_all_hooks
        called.should be_false
      end
    end
  end

  describe "#run_after_each_hooks" do
    it "runs a single hook" do
      called = false
      hooks = new_hooks(after_each: ->{ called = true; nil })
      group = new_nested_group(hooks)
      group.run_after_each_hooks
      called.should be_true
    end

    it "runs multiple hooks" do
      call_count = 0
      hooks = new_hooks(after_each: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_nested_group(hooks)
      group.run_after_each_hooks
      call_count.should eq(6)
    end

    it "runs hooks in the correct order" do
      calls = [] of Symbol
      hooks = new_hooks(after_each: [
        ->{ calls << :a; nil },
        ->{ calls << :b; nil },
        ->{ calls << :c; nil },
      ])
      group = new_nested_group(hooks)
      group.run_after_each_hooks
      calls.should eq(%i[a b c])
    end

    it "runs the parent hooks" do
      called = false
      hooks = new_hooks(after_each: ->{ called = true; nil })
      root = Spectator::RootExampleGroup.new(hooks)
      group = new_nested_group(parent: root)
      group.run_after_each_hooks
      called.should be_true
    end

    it "runs the parent hooks last" do
      calls = [] of Symbol
      root_hooks = new_hooks(after_each: ->{ calls << :a; nil })
      group_hooks = new_hooks(after_each: ->{ calls << :b; nil })
      root = Spectator::RootExampleGroup.new(root_hooks)
      group = new_nested_group(group_hooks, root)
      group.run_after_each_hooks
      calls.should eq(%i[b a])
    end

    it "runs the hooks multiple times" do
      call_count = 0
      hooks = new_hooks(after_each: ->{ call_count += 1; nil })
      group = new_nested_group(hooks)
      2.times { group.run_after_each_hooks }
      call_count.should eq(2)
    end
  end

  describe "#wrap_around_each_hooks" do
    it "wraps the block" do
      called = false
      wrapper = new_nested_group.wrap_around_each_hooks do
        called = true
      end
      wrapper.call
      called.should be_true
    end

    it "wraps a proc" do
      called = false
      hooks = new_hooks(around_each: ->(proc : ->) { called = true; proc.call })
      wrapper = new_nested_group(hooks).wrap_around_each_hooks { }
      wrapper.call
      called.should be_true
    end

    it "wraps multiple procs" do
      call_count = 0
      hooks = new_hooks(around_each: [
        ->(proc : ->) { call_count += 1; proc.call },
        ->(proc : ->) { call_count += 2; proc.call },
        ->(proc : ->) { call_count += 3; proc.call },
      ])
      wrapper = new_nested_group(hooks).wrap_around_each_hooks { }
      wrapper.call
      call_count.should eq(6)
    end

    it "wraps procs in the correct order" do
      calls = [] of Symbol
      hooks = new_hooks(around_each: [
        ->(proc : ->) { calls << :a; proc.call },
        ->(proc : ->) { calls << :b; proc.call },
        ->(proc : ->) { calls << :c; proc.call },
      ])
      wrapper = new_nested_group(hooks).wrap_around_each_hooks { }
      wrapper.call
      calls.should eq(%i[a b c])
    end

    it "wraps the parent hooks" do
      called = false
      hooks = new_hooks(around_each: ->(proc : ->) { called = true; proc.call })
      root = Spectator::RootExampleGroup.new(hooks)
      wrapper = new_nested_group(parent: root).wrap_around_each_hooks { }
      wrapper.call
      called.should be_true
    end

    it "wraps the parent hooks so they are outermost" do
      calls = [] of Symbol
      root_hooks = new_hooks(around_each: ->(proc : ->) { calls << :a; proc.call })
      group_hooks = new_hooks(around_each: ->(proc : ->) { calls << :b; proc.call })
      root = Spectator::RootExampleGroup.new(root_hooks)
      group = new_nested_group(group_hooks, root)
      wrapper = group.wrap_around_each_hooks { }
      wrapper.call
      calls.should eq(%i[a b])
    end
  end

  describe "#to_s" do
    it "contains #what" do
      group = new_nested_group
      group.to_s.should contain(group.what)
    end

    it "contains the parent's #to_s" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      parent = Spectator::NestedExampleGroup.new("PARENT", root, Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("GROUP", parent, Spectator::ExampleHooks.empty)
      root.children = [parent.as(Spectator::ExampleComponent)]
      parent.children = [group.as(Spectator::ExampleComponent)]
      group.children = [] of Spectator::ExampleComponent
      group.to_s.should contain(parent.to_s)
    end
  end

  describe "#children" do
    it "raises an error when not set" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
      root.children = [group.as(Spectator::ExampleComponent)]
      expect_raises(Exception) { group.children }
    end

    it "returns the expected set" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
      root.children = [group.as(Spectator::ExampleComponent)]
      children = Array(Spectator::ExampleComponent).new(5) do
        PassingExample.new(group, Spectator::Internals::SampleValues.empty)
      end
      group.children = children
      group.children.should eq(children)
    end
  end

  describe "#children=" do
    it "raises an error trying to reset" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
      root.children = [group.as(Spectator::ExampleComponent)]
      children = Array(Spectator::ExampleComponent).new(5) do
        PassingExample.new(group, Spectator::Internals::SampleValues.empty)
      end
      group.children = children
      expect_raises(Exception) { group.children = children }
    end
  end

  describe "#each" do
    it "yields each child" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
      root.children = [group.as(Spectator::ExampleComponent)]
      group.children = Array(Spectator::ExampleComponent).new(5) do |i|
        if i % 2 == 0
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        else
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty).tap do |sub_group|
            sub_group.children = [] of Spectator::ExampleComponent
          end
        end
      end
      group.to_a.should eq(group.children)
    end

    it "doesn't yield children of children" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
      root.children = [group.as(Spectator::ExampleComponent)]
      group.children = Array(Spectator::ExampleComponent).new(5) do |i|
        if i % 2 == 0
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        else
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty).tap do |sub_group|
            sub_group.children = Array(Spectator::ExampleComponent).new(5) do
              PassingExample.new(sub_group, Spectator::Internals::SampleValues.empty)
            end
          end
        end
      end
      group.to_a.should eq(group.children)
    end
  end

  describe "#each : Iterator" do
    it "iterates over each child" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
      root.children = [group.as(Spectator::ExampleComponent)]
      group.children = Array(Spectator::ExampleComponent).new(5) do |i|
        if i % 2 == 0
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        else
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty).tap do |sub_group|
            sub_group.children = [] of Spectator::ExampleComponent
          end
        end
      end
      group.each.to_a.should eq(group.children)
    end

    it "doesn't iterate over children of children" do
      root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
      group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
      root.children = [group.as(Spectator::ExampleComponent)]
      group.children = Array(Spectator::ExampleComponent).new(5) do |i|
        if i % 2 == 0
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        else
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty).tap do |sub_group|
            sub_group.children = Array(Spectator::ExampleComponent).new(5) do
              PassingExample.new(sub_group, Spectator::Internals::SampleValues.empty)
            end
          end
        end
      end
      group.each.to_a.should eq(group.children)
    end
  end

  describe "#example_count" do
    context "with no examples" do
      it "is zero" do
        new_nested_group.example_count.should eq(0)
      end
    end

    context "with empty sub-groups" do
      it "is zero" do
        root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
        group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
        root.children = [group.as(Spectator::ExampleComponent)]
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty)
        end
        group.example_count.should eq(0)
      end
    end

    context "with direct descendant examples" do
      it "equals the number of examples" do
        example_count = 10
        group, _ = nested_group_with_examples(example_count)
        group.example_count.should eq(example_count)
      end
    end

    context "with examples sub-groups" do
      it "equals the total number of examples" do
        sub_group_count = 3
        example_count = 10
        group, _ = nested_group_with_sub_groups(sub_group_count, example_count)
        group.example_count.should eq(sub_group_count * example_count)
      end
    end

    context "with examples at all levels" do
      it "equals the total number of examples" do
        group, examples = complex_nested_group
        group.example_count.should eq(examples.size)
      end
    end
  end

  describe "#[]" do
    context "when empty" do
      it "raises an error" do
        group = new_nested_group
        expect_raises(IndexError) { group[0] }
      end
    end

    context "with direct descendant examples" do
      context "given 0" do
        it "returns the first example" do
          group, examples = nested_group_with_examples
          group[0].should eq(examples.first)
        end
      end

      context "given -1" do
        it "returns the last example" do
          group, examples = nested_group_with_examples
          group[-1].should eq(examples.last)
        end
      end

      context "given an in-bounds positive index" do
        it "returns the expected example" do
          group, examples = nested_group_with_examples(10)
          group[3].should eq(examples[3])
        end
      end

      context "given an in-bounds negative index" do
        it "returns the expected example" do
          group, examples = nested_group_with_examples(10)
          group[-3].should eq(examples[-3])
        end
      end

      context "an out-of-bounds positive index" do
        it "raises an index error" do
          group, _ = nested_group_with_examples(10)
          expect_raises(IndexError) { group[15] }
        end

        it "handles off-by-one" do
          group, _ = nested_group_with_examples(10)
          expect_raises(IndexError) { group[10] }
        end
      end

      context "an out-of-bounds negative index" do
        it "raises an index error" do
          group, _ = nested_group_with_examples(10)
          expect_raises(IndexError) { group[-15] }
        end

        it "handles off-by-one" do
          group, _ = nested_group_with_examples(10)
          expect_raises(IndexError) { group[-11] }
        end
      end
    end

    context "with examples only in sub-groups" do
      context "given 0" do
        it "returns the first example" do
          group, examples = nested_group_with_sub_groups
          group[0].should eq(examples.first)
        end
      end

      context "given -1" do
        it "returns the last example" do
          group, examples = nested_group_with_sub_groups
          group[-1].should eq(examples.last)
        end
      end

      context "given an in-bounds positive index" do
        it "returns the expected example" do
          group, examples = nested_group_with_sub_groups(10, 2)
          group[6].should eq(examples[6])
        end
      end

      context "given an in-bounds negative index" do
        it "returns the expected example" do
          group, examples = nested_group_with_sub_groups(10, 2)
          group[-6].should eq(examples[-6])
        end
      end

      context "an out-of-bounds positive index" do
        it "raises an index error" do
          group, _ = nested_group_with_sub_groups(10, 2)
          expect_raises(IndexError) { group[25] }
        end

        it "handles off-by-one" do
          group, _ = nested_group_with_sub_groups(10, 2)
          expect_raises(IndexError) { group[20] }
        end
      end

      context "an out-of-bounds negative index" do
        it "raises an index error" do
          group, _ = nested_group_with_sub_groups(10, 2)
          expect_raises(IndexError) { group[-25] }
        end

        it "handles off-by-one" do
          group, _ = nested_group_with_sub_groups(10, 2)
          expect_raises(IndexError) { group[-21] }
        end
      end
    end

    context "with examples at all levels" do
      context "given 0" do
        it "returns the first example" do
          group, examples = complex_nested_group
          group[0].should eq(examples.first)
        end
      end

      context "given -1" do
        it "returns the last example" do
          group, examples = complex_nested_group
          group[-1].should eq(examples.last)
        end
      end

      context "given an in-bounds positive index" do
        it "returns the expected example" do
          group, examples = complex_nested_group
          group[42].should eq(examples[42])
        end
      end

      context "given an in-bounds negative index" do
        it "returns the expected example" do
          group, examples = complex_nested_group
          group[-42].should eq(examples[-42])
        end
      end

      context "an out-of-bounds positive index" do
        it "raises an index error" do
          group, examples = complex_nested_group
          expect_raises(IndexError) { group[examples.size + 5] }
        end

        it "handles off-by-one" do
          group, examples = complex_nested_group
          expect_raises(IndexError) { group[examples.size] }
        end
      end

      context "an out-of-bounds negative index" do
        it "raises an index error" do
          group, examples = complex_nested_group
          expect_raises(IndexError) { group[-examples.size - 5] }
        end

        it "handles off-by-one" do
          group, examples = complex_nested_group
          expect_raises(IndexError) { group[-examples.size - 1] }
        end
      end
    end

    context "with only sub-groups and no examples" do
      it "raises an index error" do
        root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
        group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
        root.children = [group.as(Spectator::ExampleComponent)]
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty).tap do |sub_group|
            sub_group.children = [] of Spectator::ExampleComponent
          end
        end
        expect_raises(IndexError) { group[0] }
      end
    end
  end

  describe "#finished?" do
    context "with no children" do
      it "is true" do
        new_nested_group.finished?.should be_true
      end
    end

    context "with all unfinished children" do
      it "is false" do
        group, _ = nested_group_with_examples
        group.finished?.should be_false
      end
    end

    context "with some finished children" do
      it "is false" do
        group, examples = nested_group_with_examples
        examples.each_with_index do |example, index|
          Spectator::Internals::Harness.run(example) if index % 2 == 0
        end
        group.finished?.should be_false
      end
    end

    context "with all finished children" do
      it "is true" do
        group, examples = nested_group_with_examples
        examples.each do |example|
          Spectator::Internals::Harness.run(example)
        end
        group.finished?.should be_true
      end
    end

    context "with a sub-group" do
      context "with no children" do
        it "is true" do
          root = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty)
          group = Spectator::NestedExampleGroup.new("what", root, Spectator::ExampleHooks.empty)
          root.children = [group.as(Spectator::ExampleComponent)]
          group.children = Array(Spectator::ExampleComponent).new(5) do |i|
            Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty).tap do |sub_group|
              sub_group.children = [] of Spectator::ExampleComponent
            end
          end
          group.finished?.should be_true
        end
      end

      context "with all unfinished children" do
        it "is false" do
          group, _ = nested_group_with_sub_groups
          group.finished?.should be_false
        end
      end

      context "with some finished children" do
        it "is false" do
          group, examples = nested_group_with_sub_groups
          examples.each_with_index do |example, index|
            Spectator::Internals::Harness.run(example) if index % 2 == 0
          end
          group.finished?.should be_false
        end
      end

      context "with all finished children" do
        it "is true" do
          group, examples = nested_group_with_sub_groups
          examples.each do |example|
            Spectator::Internals::Harness.run(example)
          end
          group.finished?.should be_true
        end
      end
    end
  end
end
