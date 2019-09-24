require "../spec_helper"

SAMPLE_VALUES_COLLECTION = %i[foo bar baz]

struct SampleValueCollection
  def initialize(sample_values : ::Spectator::Internals::SampleValues)
  end

  def create
    SAMPLE_VALUES_COLLECTION
  end
end

describe Spectator::DSL::SampleExampleGroupBuilder do
  describe "#add_child" do
    it "creates the correct number of children" do
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
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
      all_children.size.should eq(2 * count * SAMPLE_VALUES_COLLECTION.size)
    end

    context "with an ExampleFactory" do
      it "creates an example for each item in the collection" do
        create_proc = ->(s : SampleValueCollection) { s.create }
        builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
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
        create_proc = ->(s : SampleValueCollection) { s.create }
        builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
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
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_before_all_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_hooks
      hook_called.should eq(true)
    end

    it "attachs the hook to just the top-level group" do
      call_count = 0
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_before_all_hook(->{
        call_count += 1
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.map(&.as(Spectator::ExampleGroup)).each(&.run_before_hooks)
      call_count.should eq(1)
    end

    it "supports multiple hooks" do
      call_count = 0
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      5.times do |i|
        builder.add_before_all_hook(->{
          call_count += i + 1
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_hooks
      call_count.should eq(15)
    end
  end

  describe "#add_before_each_hook" do
    it "adds a hook" do
      hook_called = false
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_before_each_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_hooks
      hook_called.should eq(true)
    end

    it "attachs the hook to just the top-level group" do
      call_count = 0
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_before_each_hook(->{
        call_count += 1
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.map(&.as(Spectator::ExampleGroup)).each(&.run_before_hooks)
      call_count.should eq(SAMPLE_VALUES_COLLECTION.size)
    end

    it "supports multiple hooks" do
      call_count = 0
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      5.times do |i|
        builder.add_before_each_hook(->{
          call_count += i + 1
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_hooks
      call_count.should eq(15)
    end
  end

  describe "#add_after_all_hook" do
    it "adds a hook" do
      hook_called = false
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_after_all_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_hooks
      hook_called.should eq(true)
    end

    it "attachs the hook to just the top-level group" do
      call_count = 0
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_after_all_hook(->{
        call_count += 1
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.map(&.as(Spectator::ExampleGroup)).each(&.run_after_hooks)
      call_count.should eq(1)
    end

    it "supports multiple hooks" do
      call_count = 0
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      5.times do |i|
        builder.add_after_all_hook(->{
          call_count += i + 1
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_hooks
      call_count.should eq(15)
    end
  end

  describe "#add_after_each_hook" do
    it "adds a hook" do
      hook_called = false
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_after_each_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_hooks
      hook_called.should eq(true)
    end

    it "attachs the hook to just the top-level group" do
      call_count = 0
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_after_each_hook(->{
        call_count += 1
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.map(&.as(Spectator::ExampleGroup)).each(&.run_after_hooks)
      call_count.should eq(SAMPLE_VALUES_COLLECTION.size)
    end

    it "supports multiple hooks" do
      call_count = 0
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      5.times do |i|
        builder.add_after_each_hook(->{
          call_count += i + 1
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_hooks
      call_count.should eq(15)
    end
  end

  describe "#build" do
    it "passes along the what value" do
      what = "TEST"
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new(what, SampleValueCollection, create_proc, "value", :foo)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.what.should eq(what)
    end

    it "passes along the parent" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_child(factory)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.parent.should be(root)
    end

    it "passes along the sample values" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      builder.add_child(factory)
      symbol = :test
      values = Spectator::Internals::SampleValues.empty.add(symbol, "foo", 12345)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, values)
      all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
      all_children.map(&.as(SpyExample)).all? { |child| child.sample_values.get_wrapper(symbol) }.should be_true
    end

    it "passes along the value name" do
      symbol = :foo
      name = "value"
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, name, symbol)
      builder.add_child(factory)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
      all_children.each do |child|
        entries = child.as(SpyExample).sample_values.map(&.name)
        entries.should contain(name)
      end
    end

    it "creates the correct number of sub-groups" do
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
      factory = Spectator::DSL::ExampleFactory.new(PassingExample)
      builder.add_child(factory)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.size.should eq(SAMPLE_VALUES_COLLECTION.size)
    end

    it "passes the correct value to each sub-group" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      symbol = :test
      count = 3
      expected = Array.new(SAMPLE_VALUES_COLLECTION.size * count) { |i| SAMPLE_VALUES_COLLECTION[i // count] }
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", symbol)
      count.times { builder.add_child(factory) }
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      all_children = group.map { |child| child.as(Spectator::ExampleGroup).to_a }.flatten
      all_children.map { |child| child.as(SpyExample).sample_values.get_value(symbol, typeof(SAMPLE_VALUES_COLLECTION.first)) }.should eq(expected)
    end

    it "specifies the parent of the children correctly" do
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
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
      create_proc = ->(s : SampleValueCollection) { s.create }
      builder = Spectator::DSL::SampleExampleGroupBuilder.new("foobar", SampleValueCollection, create_proc, "value", :foo)
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
