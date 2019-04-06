require "./spec_helper"

describe Spectator::ExampleIterator do
  describe "#next" do
    context "with one example" do
      it "returns the example" do
        example = PassingExample.create
        iterator = Spectator::ExampleIterator.new(example.group)
        iterator.next.should eq(example)
      end

      it "returns 'stop' after the example" do
        example = PassingExample.create
        iterator = Spectator::ExampleIterator.new(example.group)
        iterator.next # Should return example.
        iterator.next.should be_a(Iterator::Stop)
      end
    end

    context "when empty" do
      it "returns 'stop'" do
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = [] of Spectator::ExampleComponent
        iterator = Spectator::ExampleIterator.new(group)
        iterator.next.should be_a(Iterator::Stop)
      end
    end

    context "with one level of examples" do
      it "iterates through all examples" do
        examples = [] of Spectator::Example
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        end
        iterator = Spectator::ExampleIterator.new(group)
        5.times { examples << iterator.next.as(Spectator::Example) }
        examples.should eq(group.children)
      end

      it "returns 'stop' at the end" do
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do
          PassingExample.new(group, Spectator::Internals::SampleValues.empty)
        end
        iterator = Spectator::ExampleIterator.new(group)
        5.times { iterator.next }
        iterator.next.should be_a(Iterator::Stop)
      end
    end

    context "with empty sub-groups" do
      context "one level deep" do
        it "returns 'stop'" do
          group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
          group.children = Array(Spectator::ExampleComponent).new(5) do |i|
            Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
              sub_group.children = [] of Spectator::ExampleComponent
            end
          end
          iterator = Spectator::ExampleIterator.new(group)
          iterator.next.should be_a(Iterator::Stop)
        end
      end

      context "multiple levels deep" do
        it "returns 'stop'" do
          group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
          group.children = Array(Spectator::ExampleComponent).new(5) do |i|
            Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
              sub_group.children = Array(Spectator::ExampleComponent).new(5) do |j|
                Spectator::NestedExampleGroup.new(j.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_sub_group|
                  sub_sub_group.children = [] of Spectator::ExampleComponent
                end
              end
            end
          end
          iterator = Spectator::ExampleIterator.new(group)
          iterator.next.should be_a(Iterator::Stop)
        end
      end
    end

    context "with multiple levels of examples" do
      it "iterates through all examples" do
        actual_examples = [] of Spectator::Example
        expected_examples = [] of Spectator::Example
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          if i % 2 == 0
            PassingExample.new(group, Spectator::Internals::SampleValues.empty).tap do |example|
              expected_examples << example
            end
          else
            Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group|
              sub_group.children = Array(Spectator::ExampleComponent).new(5) do
                PassingExample.new(sub_group, Spectator::Internals::SampleValues.empty).tap do |example|
                  expected_examples << example
                end
              end
            end
          end
        end
        iterator = Spectator::ExampleIterator.new(group)
        13.times { actual_examples << iterator.next.as(Spectator::Example) }
        actual_examples.should eq(expected_examples)
      end

      it "returns 'stop' at the end" do
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
        iterator = Spectator::ExampleIterator.new(group)
        13.times { iterator.next }
        iterator.next.should be_a(Iterator::Stop)
      end
    end

    context "with deep nesting" do
      # Sorry for this atrocity,
      # but it was fun to write.
      it "iterates through all examples" do
        actual_examples = [] of Spectator::Example
        expected_examples = [] of Spectator::Example
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group1|
            sub_group1.children = Array(Spectator::ExampleComponent).new(5) do |j|
              Spectator::NestedExampleGroup.new(j.to_s, sub_group1, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group2|
                sub_group2.children = Array(Spectator::ExampleComponent).new(5) do |k|
                  Spectator::NestedExampleGroup.new(k.to_s, sub_group2, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group3|
                    sub_group3.children = Array(Spectator::ExampleComponent).new(5) do
                      PassingExample.new(sub_group3, Spectator::Internals::SampleValues.empty).tap do |example|
                        expected_examples << example
                      end
                    end
                  end
                end
              end
            end
          end
        end
        iterator = Spectator::ExampleIterator.new(group)
        (5 ** 4).times { actual_examples << iterator.next.as(Spectator::Example) }
        actual_examples.should eq(expected_examples)
      end

      it "returns 'stop' at the end" do
        group = Spectator::RootExampleGroup.new(Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty)
        group.children = Array(Spectator::ExampleComponent).new(5) do |i|
          Spectator::NestedExampleGroup.new(i.to_s, group, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group1|
            sub_group1.children = Array(Spectator::ExampleComponent).new(5) do |j|
              Spectator::NestedExampleGroup.new(j.to_s, sub_group1, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group2|
                sub_group2.children = Array(Spectator::ExampleComponent).new(5) do |k|
                  Spectator::NestedExampleGroup.new(k.to_s, sub_group2, Spectator::ExampleHooks.empty, Spectator::ExampleConditions.empty).tap do |sub_group3|
                    sub_group3.children = Array(Spectator::ExampleComponent).new(5) do
                      PassingExample.new(sub_group3, Spectator::Internals::SampleValues.empty)
                    end
                  end
                end
              end
            end
          end
        end
        iterator = Spectator::ExampleIterator.new(group)
        (5 ** 4).times { iterator.next }
        iterator.next.should be_a(Iterator::Stop)
      end
    end

    it "returns 'stop' after the end has been reached" do
      example = PassingExample.create
      iterator = Spectator::ExampleIterator.new(example.group)
      iterator.next                             # Should return example.
      iterator.next                             # Should return "stop".
      iterator.next.should be_a(Iterator::Stop) # Should still return "stop".
    end
  end

  describe "#rewind" do
    it "restarts the iterator" do
      example = PassingExample.create
      iterator = Spectator::ExampleIterator.new(example.group)
      iterator.next
      iterator.rewind
      iterator.next.should eq(example)
    end

    it "can be called before #next" do
      example = PassingExample.create
      iterator = Spectator::ExampleIterator.new(example.group)
      iterator.rewind
      iterator.next.should eq(example)
    end
  end
end
