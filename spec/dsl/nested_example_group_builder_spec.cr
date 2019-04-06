require "../spec_helper"

describe Spectator::DSL::NestedExampleGroupBuilder do
  describe "#add_child" do
    it "creates the correct number of children" do
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      3.times do
        factory = Spectator::DSL::ExampleFactory.new(PassingExample)
        group_builder = Spectator::DSL::NestedExampleGroupBuilder.new("bar")
        builder.add_child(factory)
        builder.add_child(group_builder)
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.children.size.should eq(6)
    end

    context "with an ExampleFactory" do
      it "creates the example" do
        builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
        factory = Spectator::DSL::ExampleFactory.new(PassingExample)
        builder.add_child(factory)
        root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
        group = builder.build(root, Spectator::Internals::SampleValues.empty)
        group.children.first.should be_a(PassingExample)
      end
    end

    context "with an ExampleGroupBuilder" do
      it "creates the group" do
        builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
        group_builder = Spectator::DSL::NestedExampleGroupBuilder.new("bar")
        builder.add_child(group_builder)
        root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
        group = builder.build(root, Spectator::Internals::SampleValues.empty)
        group.children.first.should be_a(Spectator::NestedExampleGroup)
      end
    end
  end

  describe "#add_before_all_hook" do
    it "adds a hook" do
      hook_called = false
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      builder.add_before_all_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_hooks
      hook_called.should eq(true)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
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
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      builder.add_before_each_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_before_hooks
      hook_called.should eq(true)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
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
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      builder.add_after_all_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_hooks
      hook_called.should eq(true)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
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
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      builder.add_after_each_hook(->{
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.run_after_hooks
      hook_called.should eq(true)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
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

  describe "#add_around_each_hook" do
    it "adds a hook" do
      hook_called = false
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      builder.add_around_each_hook(->(_proc : ->) {
        hook_called = true
      })
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      proc = group.wrap_around_each_hooks { }
      proc.call
      hook_called.should eq(true)
    end

    it "supports multiple hooks" do
      call_count = 0
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      5.times do |i|
        builder.add_around_each_hook(->(proc : ->) {
          call_count += i + 1
          proc.call
        })
      end
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      proc = group.wrap_around_each_hooks { }
      proc.call
      call_count.should eq(15)
    end
  end

  describe "#build" do
    it "passes along the what value" do
      what = "TEST"
      builder = Spectator::DSL::NestedExampleGroupBuilder.new(what)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.what.should eq(what)
    end

    it "passes along the parent" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      builder.add_child(factory)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, Spectator::Internals::SampleValues.empty)
      group.parent.should be(root)
    end

    it "passes along the sample values" do
      factory = Spectator::DSL::ExampleFactory.new(SpyExample)
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      builder.add_child(factory)
      values = Spectator::Internals::SampleValues.empty.add(:foo, "foo", 12345)
      root = Spectator::DSL::RootExampleGroupBuilder.new.build(Spectator::Internals::SampleValues.empty)
      group = builder.build(root, values)
      group.children.first.as(SpyExample).sample_values.should eq(values)
    end

    it "specifies the parent of the children correctly" do
      builder = Spectator::DSL::NestedExampleGroupBuilder.new("foo")
      3.times do
        factory = Spectator::DSL::ExampleFactory.new(PassingExample)
        group_builder = Spectator::DSL::NestedExampleGroupBuilder.new("bar")
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
