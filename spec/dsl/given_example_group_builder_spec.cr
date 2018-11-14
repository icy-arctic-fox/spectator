require "../spec_helper"

describe Spectator::DSL::GivenExampleGroupBuilder do
  describe "#add_child" do
    it "creates the correct number of children" do
      collection = %i[foo bar baz]
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", collection, "value", :foo)
      count = 4
      count.times do
        factory = Spectator::DSL::ExampleFactory.new(PassingExample)
        group_builder = Spectator::DSL::NestedExampleGroupBuilder.new("bar")
        builder.add_child(factory)
        builder.add_child(group_builder)
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
      all_children.size.should eq(2 * count * collection.size)
    end

    context "with an ExampleFactory" do
      it "creates an example for each item in the collection" do
        collection = %i[foo bar baz]
        builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", collection, "value", :foo)
        factory = Spectator::DSL::ExampleFactory.new(PassingExample)
        builder.add_child(factory)
        root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
        group = builder.build(root, Spectator::Internals::SampleValues.empty)
        all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
        all_children.all? { |child| child.is_a?(PassingExample) }.should be_true
      end
    end

    context "with an ExampleGroupBuilder" do
      it "creates a group for each item in the collection" do
        collection = %i[foo bar baz]
        builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", collection, "value", :foo)
        group_builder = Spectator::DSL::NestedExampleGroupBuilder.new("bar")
        builder.add_child(group_builder)
        root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
        group = builder.build(root, Spectator::Internals::SampleValues.empty)
        all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
        all_children.all? { |child| child.is_a?(Spectator::NestedExampleGroup) }.should be_true
      end
    end
  end

  describe "#add_before_all_hook" do
    it "adds a hook" do
      hook_called = false
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      builder.add_before_all_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_all_hooks
      hook_called.should eq(true)
    end

    it "attachs the hook to just the top-level group" do
      call_count = 0
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      builder.add_before_all_hook(->{
        call_count += 1
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.map(&.as(Spectator::ExampleGroup)).each(&.run_before_all_hooks)
      call_count.should eq(1)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      5.times do |i|
        builder.add_before_all_hook(->{
          call_count += i + 1
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_all_hooks
      call_count.should eq(15)
    end
  end

  describe "#add_before_each_hook" do
    it "adds a hook" do
      hook_called = false
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      builder.add_before_each_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_each_hooks
      hook_called.should eq(true)
    end

    it "attachs the hook to just the top-level group" do
      call_count = 0
      collection = %i[foo bar]
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", collection, "value", :foo)
      builder.add_before_each_hook(->{
        call_count += 1
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.map(&.as(Spectator::ExampleGroup)).each(&.run_before_each_hooks)
      call_count.should eq(collection.size)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      5.times do |i|
        builder.add_before_each_hook(->{
          call_count += i + 1
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_each_hooks
      call_count.should eq(15)
    end
  end

  describe "#add_after_all_hook" do
    it "adds a hook" do
      hook_called = false
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      builder.add_after_all_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_all_hooks
      hook_called.should eq(true)
    end

    it "attachs the hook to just the top-level group" do
      call_count = 0
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      builder.add_after_all_hook(->{
        call_count += 1
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.map(&.as(Spectator::ExampleGroup)).each(&.run_after_all_hooks)
      call_count.should eq(1)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      5.times do |i|
        builder.add_after_all_hook(->{
          call_count += i + 1
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_all_hooks
      call_count.should eq(15)
    end
  end

  describe "#add_after_each_hook" do
    it "adds a hook" do
      hook_called = false
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      builder.add_after_each_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_each_hooks
      hook_called.should eq(true)
    end

    it "attachs the hook to just the top-level group" do
      call_count = 0
      collection = %i[foo bar]
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", collection, "value", :foo)
      builder.add_after_each_hook(->{
        call_count += 1
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.map(&.as(Spectator::ExampleGroup)).each(&.run_after_each_hooks)
      call_count.should eq(collection.size)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      5.times do |i|
        builder.add_after_each_hook(->{
          call_count += i + 1
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_each_hooks
      call_count.should eq(15)
    end
  end

  describe "#build" do
    it "passes along the what value" do
      what = "TEST"
      builder = Spectator::DSL::GivenExampleGroupBuilder.new(what, %i[foo bar], "value", :foo)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.what.should eq(what)
    end

    it "passes along the parent" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      builder.add_child(factory)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.parent.should be(root)
    end

    it "passes along the sample values" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      builder.add_child(factory)
      symbol = :test
      values = Spectator::Internals::SampleValues.empty.add(symbol, "foo", 12345)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, values)
      all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
      all_children.map(&.as(SpyExample)).all? { |child| child.sample_values.get_wrapper(symbol) }.should be_true
    end

    pending "it passes along the given value name" do
      symbol = :foo
      name = "value"
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], name, symbol)
      builder.add_child(factory)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
      # TODO: Ensure that all children have sample values with the name given to the builder.
      # There is currently no method to retrieve the value's name.
    end

    it "creates the correct number of sub-groups" do
      collection = %i[foo bar baz]
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", collection, "value", :foo)
      factory = Spectator::DSL::ExampleFactory.new(PassingExample)
      builder.add_child(factory)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.size.should eq(collection.size)
    end

    it "passes the correct value to each sub-group" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      symbol = :test
      count = 3
      collection = %i[foo bar baz]
      expected = Array.new(collection.size * count) { |i| collection[i / count] }
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", collection, "value", symbol)
      count.times { builder.add_child(factory) }
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
      all_children.map { |child| child.as(SpyExample).sample_values.get_value(symbol, typeof(collection.first)) }.should eq(expected)
    end

    it "specifies the parent of the children correctly" do
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      3.times do
        factory = Spectator::DSL::ExampleFactory.new(PassingExample)
        group_builder = Spectator::DSL::NestedExampleGroupBuilder.new("baz")
        builder.add_child(factory)
        builder.add_child(group_builder)
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.all? do |child|
        case (child)
        when Spectator::Example
          child.group == group
        when Spectator::NestedExampleGroup
          child.parent == group
        else
          false
        end
      end.should be_true
    end

    it "specifies the container for the parent of the sub-groups" do
      builder = Spectator::DSL::GivenExampleGroupBuilder.new("foobar", %i[foo bar], "value", :foo)
      3.times do
        factory = Spectator::DSL::ExampleFactory.new(PassingExample)
        group_builder = Spectator::DSL::NestedExampleGroupBuilder.new("baz")
        builder.add_child(factory)
        builder.add_child(group_builder)
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.all? do |child|
        case (child)
        when Spectator::Example
          child.group == group
        when Spectator::NestedExampleGroup
          child.parent == group
        else
          false
        end
      end.should be_true
    end
  end
end