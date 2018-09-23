module Spectator
  module DSL
    module Builder
      extend self

      @group_stack = [ExampleGroupBuilder.new]

      private def current_group
        @group_stack.last
      end

      private def push_group(group : ExampleGroupBuilder)
        current_group.add_child(group)
        @group_stack.push(group)
      end

      def start_group(what : String) : Nil
        push_group(ExampleGroupBuilder.new(what))
      end

      def start_given_group(what : String, values : Array(ValueWrapper)) : Nil
        push_group(GivenExampleGroupBuilder.new(what, values))
      end

      def end_group : Nil
        @group_stack.pop
      end

      def add_example(factory : AbstractExampleFactory) : Nil
        current_group.add_child(factory)
      end

      def add_before_all_hook(&block : ->) : Nil
        current_group.add_before_all_hook(block)
      end

      def add_before_each_hook(&block : ->) : Nil
        current_group.add_before_each_hook(block)
      end

      def add_after_all_hook(&block : ->) : Nil
        current_group.add_after_all_hook(block)
      end

      def add_after_each_hook(&block : ->) : Nil
        current_group.add_after_each_hook(block)
      end

      def add_around_each_hook(&block : Proc(Nil) ->) : Nil
        current_group.add_around_each_hook(block)
      end

      protected def build : Array(Example)
        # TODO
        ExampleGroup.new
      end
    end
  end
end
