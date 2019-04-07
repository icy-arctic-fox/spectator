require "./spec_helper"

def new_root_group(hooks = Spectator::ExampleHooks.empty, conditions = Spectator::ExampleConditions.empty)
  Spectator::RootExampleGroup.new(hooks, conditions).tap do |group|
    group.children = [] of Spectator::ExampleComponent
  end
end

def root_group_with_examples(example_count = 5)
  group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
  examples = [] of Spectator::Example
  group.children = Array(Spectator::ExampleComponent).new(example_count) do
    PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
      examples << example
    end
  end
  {group, examples}
end

def root_group_with_sub_groups(sub_group_count = 5, example_count = 5)
  group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
  examples = [] of Spectator::Example
  group.children = Array(Spectator::ExampleComponent).new(sub_group_count) do |i|
    Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
      sub_group.children = Array(Spectator::ExampleComponent).new(example_count) do
        PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
          examples << example
        end
      end
    end
  end
  {group, examples}
end

def complex_root_group
  group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
  examples = [] of Spectator::Example
  group.children = Array(Spectator::ExampleComponent).new(10) do |i|
    if i % 2 == 0
      PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
        examples << example
      end
    else
      Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group1|
        sub_group1.children = Array(Spectator::ExampleComponent).new(10) do |j|
          if i % 2 == 0
            PassingExample.new(sub_group1, Spectator::Internals::SampleValues.empty).tap do |example|
              examples << example
            end
          else
            Spectator::NestedExampleGroup.new(j.to_s, sub_group1, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group2|
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

describe Spectator::RootExampleGroup do
  describe "#run_before_hooks" do
    it "runs a before_all hook" do
      called = false
      hooks = new_hooks(before_all: ->{ called = true; nil })
      group = new_root_group(hooks)
      group.run_before_hooks
      called.should be_true
    end

    it "runs a before_each hook" do
      called = false
      hooks = new_hooks(before_each: ->{ called = true; nil })
      group = new_root_group(hooks)
      group.run_before_hooks
      called.should be_true
    end

    it "runs multiple before_all hooks" do
      call_count = 0
      hooks = new_hooks(before_all: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_root_group(hooks)
      group.run_before_hooks
      call_count.should eq(6)
    end

    it "runs multiple before_each hooks" do
      call_count = 0
      hooks = new_hooks(before_each: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_root_group(hooks)
      group.run_before_hooks
      call_count.should eq(6)
    end

    it "runs hooks in the correct order" do
      calls = [] of Symbol
      hooks = new_hooks(before_all: [
        ->{ calls << :a; nil },
        ->{ calls << :b; nil },
        ->{ calls << :c; nil },
      ],
        before_each: [
          ->{ calls << :d; nil },
          ->{ calls << :e; nil },
          ->{ calls << :f; nil },
        ])
      group = new_root_group(hooks)
      group.run_before_hooks
      calls.should eq(%i[a b c d e f])
    end

    it "runs the before_all hooks once" do
      call_count = 0
      hooks = new_hooks(before_all: ->{ call_count += 1; nil })
      group = new_root_group(hooks)
      2.times { group.run_before_hooks }
      call_count.should eq(1)
    end

    it "runs the before_each hooks multiple times" do
      call_count = 0
      hooks = new_hooks(before_each: ->{ call_count += 1; nil })
      group = new_root_group(hooks)
      2.times { group.run_before_hooks }
      call_count.should eq(2)
    end
  end

  describe "#run_after_hooks" do
    # No children are used for most of these examples.
    # That's because `[].all?` is always true.
    # Which means that all examples are considered finished, since there are none.
    it "runs a single after_all hook" do
      called = false
      hooks = new_hooks(after_all: ->{ called = true; nil })
      group = new_root_group(hooks)
      group.run_after_hooks
      called.should be_true
    end

    it "runs a single after_each hook" do
      called = false
      hooks = new_hooks(after_each: ->{ called = true; nil })
      group = new_root_group(hooks)
      group.run_after_hooks
      called.should be_true
    end

    it "runs multiple after_all hooks" do
      call_count = 0
      hooks = new_hooks(after_all: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_root_group(hooks)
      group.run_after_hooks
      call_count.should eq(6)
    end

    it "runs multiple after_each hooks" do
      call_count = 0
      hooks = new_hooks(after_all: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_root_group(hooks)
      group.run_after_hooks
      call_count.should eq(6)
    end

    it "runs hooks in the correct order" do
      calls = [] of Symbol
      hooks = new_hooks(after_each: [
        ->{ calls << :a; nil },
        ->{ calls << :b; nil },
        ->{ calls << :c; nil },
      ],
        after_all: [
          ->{ calls << :d; nil },
          ->{ calls << :e; nil },
          ->{ calls << :f; nil },
        ])
      group = new_root_group(hooks)
      group.run_after_hooks
      calls.should eq(%i[a b c d e f])
    end

    it "runs the after_all hooks once" do
      call_count = 0
      hooks = new_hooks(after_all: ->{ call_count += 1; nil })
      group = new_root_group(hooks)
      2.times { group.run_after_hooks }
      call_count.should eq(1)
    end

    it "runs the after_each hooks multiple times" do
      call_count = 0
      hooks = new_hooks(after_each: ->{ call_count += 1; nil })
      group = new_root_group(hooks)
      2.times { group.run_after_hooks }
      call_count.should eq(2)
    end

    context "with no examples finished" do
      it "doesn't run the after_all hooks" do
        called = false
        hooks = new_hooks(after_all: ->{ called = true; nil })
        group = Spectator::RootExampleGroup.new(hooks, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        end
        group.run_after_hooks
        called.should be_false
      end

      it "runs the after_each hooks" do
        called = false
        hooks = new_hooks(after_each: ->{ called = true; nil })
        group = Spectator::RootExampleGroup.new(hooks, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        end
        group.run_after_hooks
        called.should be_true
      end
    end

    context "with some examples finished" do
      it "doesn't run the after_all hooks" do
        called = false
        examples = [] of Spectator::Example
        hooks = new_hooks(after_all: ->{ called = true; nil })
        group = Spectator::RootExampleGroup.new(hooks, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do
          PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
            examples << example
          end
        end
        examples.each_with_index do |example, index|
          Spectator::Internals::Harness.run(example) if index % 2 == 0
        end
        group.run_after_hooks
        called.should be_false
      end

      it "runs the after_each hooks" do
        called = false
        examples = [] of Spectator::Example
        hooks = new_hooks(after_each: ->{ called = true; nil })
        group = Spectator::RootExampleGroup.new(hooks, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do
          PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
            examples << example
          end
        end
        examples.each_with_index do |example, index|
          Spectator::Internals::Harness.run(example) if index % 2 == 0
        end
        group.run_after_hooks
        called.should be_true
      end
    end
  end

  describe "#wrap_around_each_hooks" do
    it "wraps the block" do
      called = false
      wrapper = new_root_group.wrap_around_each_hooks do
        called = true
      end
      wrapper.call
      called.should be_true
    end

    it "wraps a proc" do
      called = false
      hooks = new_hooks(around_each: ->(proc : ->) { called = true; proc.call })
      wrapper = new_root_group(hooks).wrap_around_each_hooks { }
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
      wrapper = new_root_group(hooks).wrap_around_each_hooks { }
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
      wrapper = new_root_group(hooks).wrap_around_each_hooks { }
      wrapper.call
      calls.should eq(%i[a b c])
    end
  end

  describe "#run_pre_conditions" do
    it "runs a condition" do
      called = false
      conditions = new_conditions(pre: ->{ called = true; nil })
      group = new_root_group(conditions: conditions)
      group.run_pre_conditions
      called.should be_true
    end

    it "runs multiple conditions" do
      call_count = 0
      conditions = new_conditions(pre: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_root_group(conditions: conditions)
      group.run_pre_conditions
      call_count.should eq(6)
    end

    it "runs conditions in the correct order" do
      calls = [] of Symbol
      conditions = new_conditions(pre: [
        ->{ calls << :a; nil },
        ->{ calls << :b; nil },
        ->{ calls << :c; nil },
      ])
      group = new_root_group(conditions: conditions)
      group.run_pre_conditions
      calls.should eq(%i[a b c])
    end

    it "runs the conditions multiple times" do
      call_count = 0
      conditions = new_conditions(pre: ->{ call_count += 1; nil })
      group = new_root_group(conditions: conditions)
      2.times { group.run_pre_conditions }
      call_count.should eq(2)
    end
  end

  describe "#run_post_conditions" do
    it "runs a single condition" do
      called = false
      conditions = new_conditions(post: ->{ called = true; nil })
      group = new_root_group(conditions: conditions)
      group.run_post_conditions
      called.should be_true
    end

    it "runs multiple conditions" do
      call_count = 0
      conditions = new_conditions(post: [
        ->{ call_count += 1; nil },
        ->{ call_count += 2; nil },
        ->{ call_count += 3; nil },
      ])
      group = new_root_group(conditions: conditions)
      group.run_post_conditions
      call_count.should eq(6)
    end

    it "runs conditions in the correct order" do
      calls = [] of Symbol
      conditions = new_conditions(post: [
        ->{ calls << :a; nil },
        ->{ calls << :b; nil },
        ->{ calls << :c; nil },
      ])
      group = new_root_group(conditions: conditions)
      group.run_post_conditions
      calls.should eq(%i[a b c])
    end

    it "runs the conditions multiple times" do
      call_count = 0
      conditions = new_conditions(post: ->{ call_count += 1; nil })
      group = new_root_group(conditions: conditions)
      2.times { group.run_post_conditions }
      call_count.should eq(2)
    end
  end

  describe "#to_s" do
    it "is empty" do
      new_root_group.to_s.should be_empty
    end
  end

  describe "#children" do
    it "raises an error when not set" do
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      expect_raises(Exception) { group.children }
    end

    it "returns the expected set" do
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      children = Array(Spectator::ExampleComponent).new(5) do
        PassingExample.new(group, Spectator::Internals::SampleValues.empty)
      end
      group.children = children
      group.children.should eq(children)
    end
  end

  describe "#children=" do
    it "raises an error trying to reset" do
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      children = Array(Spectator::ExampleComponent).new(5) do
        PassingExample.new(group, Spectator::Internals::SampleValues.empty)
      end
      group.children = children
      expect_raises(Exception) { group.children = children }
    end
  end

  describe "#each" do
    it "yields each child" do
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      group.children = Array(Spectator::ExampleComponent).new(5) do |i|
        if i % 2 == 0
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        else
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
            sub_group.children = [] of Spectator::ExampleComponent
          end
        end
      end
      group.to_a.should eq(group.children)
    end

    it "doesn't yield children of children" do
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      group.children = Array(Spectator::ExampleComponent).new(5) do |i|
        if i % 2 == 0
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        else
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
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
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      group.children = Array(Spectator::ExampleComponent).new(5) do |i|
        if i % 2 == 0
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        else
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
            sub_group.children = [] of Spectator::ExampleComponent
          end
        end
      end
      group.each.to_a.should eq(group.children)
    end

    it "doesn't iterate over children of children" do
      group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
      group.children = Array(Spectator::ExampleComponent).new(5) do |i|
        if i % 2 == 0
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        else
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
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
        new_root_group.example_count.should eq(0)
      end
    end

    context "with empty sub-groups" do
      it "is zero" do
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        end
        group.example_count.should eq(0)
      end
    end

    context "with direct descendant examples" do
      it "equals the number of examples" do
        example_count = 10
        group, _ = root_group_with_examples(example_count)
        group.example_count.should eq(example_count)
      end
    end

    context "with examples sub-groups" do
      it "equals the total number of examples" do
        sub_group_count = 3
        example_count = 10
        group, _ = root_group_with_sub_groups(sub_group_count, example_count)
        group.example_count.should eq(sub_group_count * example_count)
      end
    end

    context "with examples at all levels" do
      it "equals the total number of examples" do
        group, examples = complex_root_group
        group.example_count.should eq(examples.size)
      end
    end
  end

  describe "#[]" do
    context "when empty" do
      it "raises an error" do
        group = new_root_group
        expect_raises(IndexError) { group[0] }
      end
    end

    context "with direct descendant examples" do
      context "given 0" do
        it "returns the first example" do
          group, examples = root_group_with_examples
          group[0].should eq(examples.first)
        end
      end

      context "given -1" do
        it "returns the last example" do
          group, examples = root_group_with_examples
          group[-1].should eq(examples.last)
        end
      end

      context "given an in-bounds positive index" do
        it "returns the expected example" do
          group, examples = root_group_with_examples(10)
          group[3].should eq(examples[3])
        end
      end

      context "given an in-bounds negative index" do
        it "returns the expected example" do
          group, examples = root_group_with_examples(10)
          group[-3].should eq(examples[-3])
        end
      end

      context "an out-of-bounds positive index" do
        it "raises an index error" do
          group, _ = root_group_with_examples(10)
          expect_raises(IndexError) { group[15] }
        end

        it "handles off-by-one" do
          group, _ = root_group_with_examples(10)
          expect_raises(IndexError) { group[10] }
        end
      end

      context "an out-of-bounds negative index" do
        it "raises an index error" do
          group, _ = root_group_with_examples(10)
          expect_raises(IndexError) { group[-15] }
        end

        it "handles off-by-one" do
          group, _ = root_group_with_examples(10)
          expect_raises(IndexError) { group[-11] }
        end
      end
    end

    context "with examples only in sub-groups" do
      context "given 0" do
        it "returns the first example" do
          group, examples = root_group_with_sub_groups
          group[0].should eq(examples.first)
        end
      end

      context "given -1" do
        it "returns the last example" do
          group, examples = root_group_with_sub_groups
          group[-1].should eq(examples.last)
        end
      end

      context "given an in-bounds positive index" do
        it "returns the expected example" do
          group, examples = root_group_with_sub_groups(10, 2)
          group[6].should eq(examples[6])
        end
      end

      context "given an in-bounds negative index" do
        it "returns the expected example" do
          group, examples = root_group_with_sub_groups(10, 2)
          group[-6].should eq(examples[-6])
        end
      end

      context "an out-of-bounds positive index" do
        it "raises an index error" do
          group, _ = root_group_with_sub_groups(10, 2)
          expect_raises(IndexError) { group[25] }
        end

        it "handles off-by-one" do
          group, _ = root_group_with_sub_groups(10, 2)
          expect_raises(IndexError) { group[20] }
        end
      end

      context "an out-of-bounds negative index" do
        it "raises an index error" do
          group, _ = root_group_with_sub_groups(10, 2)
          expect_raises(IndexError) { group[-25] }
        end

        it "handles off-by-one" do
          group, _ = root_group_with_sub_groups(10, 2)
          expect_raises(IndexError) { group[-21] }
        end
      end
    end

    context "with examples at all levels" do
      context "given 0" do
        it "returns the first example" do
          group, examples = complex_root_group
          group[0].should eq(examples.first)
        end
      end

      context "given -1" do
        it "returns the last example" do
          group, examples = complex_root_group
          group[-1].should eq(examples.last)
        end
      end

      context "given an in-bounds positive index" do
        it "returns the expected example" do
          group, examples = complex_root_group
          group[42].should eq(examples[42])
        end
      end

      context "given an in-bounds negative index" do
        it "returns the expected example" do
          group, examples = complex_root_group
          group[-42].should eq(examples[-42])
        end
      end

      context "an out-of-bounds positive index" do
        it "raises an index error" do
          group, examples = complex_root_group
          expect_raises(IndexError) { group[examples.size + 5] }
        end

        it "handles off-by-one" do
          group, examples = complex_root_group
          expect_raises(IndexError) { group[examples.size] }
        end
      end

      context "an out-of-bounds negative index" do
        it "raises an index error" do
          group, examples = complex_root_group
          expect_raises(IndexError) { group[-examples.size - 5] }
        end

        it "handles off-by-one" do
          group, examples = complex_root_group
          expect_raises(IndexError) { group[-examples.size - 1] }
        end
      end
    end

    context "with only sub-groups and no examples" do
      it "raises an index error" do
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
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
        new_root_group.finished?.should be_true
      end
    end

    context "with all unfinished children" do
      it "is false" do
        group, _ = root_group_with_examples
        group.finished?.should be_false
      end
    end

    context "with some finished children" do
      it "is false" do
        group, examples = root_group_with_examples
        examples.each_with_index do |example, index|
          Spectator::Internals::Harness.run(example) if index % 2 == 0
        end
        group.finished?.should be_false
      end
    end

    context "with all finished children" do
      it "is true" do
        group, examples = root_group_with_examples
        examples.each do |example|
          Spectator::Internals::Harness.run(example)
        end
        group.finished?.should be_true
      end
    end

    context "with a sub-group" do
      context "with no children" do
        it "is true" do
          group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
          group.children = Array(Spectator::ExampleComponent).new(5) do |i|
            Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
              sub_group.children = [] of Spectator::ExampleComponent
            end
          end
          group.finished?.should be_true
        end
      end

      context "with all unfinished children" do
        it "is false" do
          group, _ = root_group_with_sub_groups
          group.finished?.should be_false
        end
      end

      context "with some finished children" do
        it "is false" do
          group, examples = root_group_with_sub_groups
          examples.each_with_index do |example, index|
            Spectator::Internals::Harness.run(example) if index % 2 == 0
          end
          group.finished?.should be_false
        end
      end

      context "with all finished children" do
        it "is true" do
          group, examples = root_group_with_sub_groups
          examples.each do |example|
            Spectator::Internals::Harness.run(example)
          end
          group.finished?.should be_true
        end
      end
    end
  end

  describe "#symbolic?" do
    it "is true" do
      new_root_group.symbolic?.should be_true
    end
  end
end
