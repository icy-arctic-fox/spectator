module Spectator::DSL
  # DSL methods for adding custom logic to key times of the spec execution.
  module Hooks
    # Defines code to run before any and all examples in an example group.
    macro before_all(&block)
      {% raise "Cannot use 'before_all' inside of a test block" if @def %}

      def self.%hook : Nil
        {{block.body}}
      end

      ::Spectator::DSL::Builder.before_all { {{@type.name}.%hook }
    end

    macro before_each(&block)
      {% raise "Cannot use 'before_each' inside of a test block" if @def %}

      def %hook : Nil
        {{block.body}}
      end

      ::Spectator::DSL::Builder.before_each { |example| example.with_context({{@type.name}) { %hook } }
    end

    macro after_all(&block)
    end

    macro after_each(&block)
    end
  end

    macro before_each(&block)
      def %hook({{block.args.splat}}) : Nil
        {{block.body}}
      end

      ::Spectator::SpecBuilder.add_before_each_hook do |test, example|
        cast_test = test.as({{@type.id}})
        {% if block.args.empty? %}
          cast_test.%hook
        {% else %}
          cast_test.%hook(example)
        {% end %}
      end
    end

    macro after_each(&block)
      def %hook({{block.args.splat}}) : Nil
        {{block.body}}
      end

      ::Spectator::SpecBuilder.add_after_each_hook do |test, example|
        cast_test = test.as({{@type.id}})
        {% if block.args.empty? %}
          cast_test.%hook
        {% else %}
          cast_test.%hook(example)
        {% end %}
      end
    end

    macro before_all(&block)
      ::Spectator::SpecBuilder.add_before_all_hook {{block}}
    end

    macro after_all(&block)
      ::Spectator::SpecBuilder.add_after_all_hook {{block}}
    end

    macro around_each(&block)
      def %hook({{block.args.first || :example.id}}) : Nil
        {{block.body}}
      end

      ::Spectator::SpecBuilder.add_around_each_hook { |test, proc| test.as({{@type.id}}).%hook(proc) }
    end

    macro pre_condition(&block)
      def %hook({{block.args.splat}}) : Nil
        {{block.body}}
      end

      ::Spectator::SpecBuilder.add_pre_condition do |test, example|
        cast_test = test.as({{@type.id}})
        {% if block.args.empty? %}
          cast_test.%hook
        {% else %}
          cast_test.%hook(example)
        {% end %}
      end
    end

    macro post_condition(&block)
      def %hook({{block.args.splat}}) : Nil
        {{block.body}}
      end

      ::Spectator::SpecBuilder.add_post_condition do |test, example|
        cast_test = test.as({{@type.id}})
        {% if block.args.empty? %}
          cast_test.%hook
        {% else %}
          cast_test.%hook(example)
        {% end %}
      end
    end
  end
end
