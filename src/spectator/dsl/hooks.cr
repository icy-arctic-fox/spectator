require "../location"
require "./builder"

module Spectator::DSL
  # DSL methods for adding custom logic to key times of the spec execution.
  module Hooks
    # Defines a macro to create an example group hook.
    # The *type* indicates when the hook runs and must be a method on `Spectator::DSL::Builder`.
    # A custom *name* can be used for the hook method.
    # If not provided, *type* will be used instead.
    # Additionally, a block can be provided.
    # The block can perform any operations necessary and yield to invoke the end-user hook.
    macro define_example_group_hook(type, name = nil, &block)
      macro {{(name ||= type).id}}(&block)
        \{% raise "Missing block for '{{name.id}}' hook" unless block %}
        \{% raise "Cannot use '{{name.id}}' inside of a test block" if @def %}

        private def self.\%hook : Nil
          \{{block.body}}
        end

        {% if block %}
          private def self.%wrapper : Nil
            {{block.body}}
          end
        {% end %}

        ::Spectator::DSL::Builder.{{type.id}}(
          ::Spectator::Location.new(\{{block.filename}}, \{{block.line_number}}, \{{block.end_line_number}})
        ) do
          {% if block %}
            %wrapper do |*args|
              \{% if block.args.empty? %}
                \%hook
              \{% else %}
                \%hook(*args)
              \{% end %}
            end
          {% else %}
            \%hook
          {% end %}
        end
      end
    end

    # Defines a macro to create an example hook.
    # The *type* indicates when the hook runs and must be a method on `Spectator::DSL::Builder`.
    # A custom *name* can be used for the hook method.
    # If not provided, *type* will be used instead.
    # Additionally, a block can be provided that takes the current example as an argument.
    # The block can perform any operations necessary and yield to invoke the end-user hook.
    macro define_example_hook(type, name = nil, &block)
      macro {{(name ||= type).id}}(&block)
        \{% raise "Missing block for '{{name.id}}' hook" unless block %}
        \{% raise "Block argument count '{{name.id}}' hook must be 0..1" if block.args.size > 1 %}
        \{% raise "Cannot use '{{name.id}}' inside of a test block" if @def %}

        private def \%hook(\{{block.args.splat}}) : Nil
          \{{block.body}}
        end

        {% if block %}
          private def %wrapper({{block.args.splat}}) : Nil
            {{block.body}}
          end
        {% end %}

        ::Spectator::DSL::Builder.{{type.id}}(
          ::Spectator::Location.new(\{{block.filename}}, \{{block.line_number}})
        ) do |example|
          example.with_context(\{{@type.name}}) do
            {% if block %}
              {% if block.args.empty? %}
                %wrapper do |*args|
                  \{% if block.args.empty? %}
                    \%hook
                  \{% else %}
                    \%hook(*args)
                  \{% end %}
                end
              {% else %}
                %wrapper(example) do |*args|
                  \{% if block.args.empty? %}
                    \%hook
                  \{% else %}
                    \%hook(*args)
                  \{% end %}
                end
              {% end %}
            {% else %}
              \{% if block.args.empty? %}
                \%hook
              \{% else %}
                \%hook(example)
              \{% end %}
            {% end %}
          end
        end
      end
    end

    # Defines a block of code that will be invoked once before any examples in the suite.
    # The block will not run in the context of the current running example.
    # This means that values defined by `let` and `subject` are not available.
    define_example_group_hook :before_suite

    # Defines a block of code that will be invoked once after all examples in the suite.
    # The block will not run in the context of the current running example.
    # This means that values defined by `let` and `subject` are not available.
    define_example_group_hook :after_suite

    # Defines a block of code that will be invoked once before any examples in the group.
    # The block will not run in the context of the current running example.
    # This means that values defined by `let` and `subject` are not available.
    define_example_group_hook :before_all

    # Defines a block of code that will be invoked once after all examples in the group.
    # The block will not run in the context of the current running example.
    # This means that values defined by `let` and `subject` are not available.
    define_example_group_hook :after_all

    # Defines a block of code that will be invoked before every example in the group.
    # The block will be run in the context of the current running example.
    # This means that values defined by `let` and `subject` are available.
    define_example_hook :before_each

    # :ditto:
    macro before(&block)
      before_each {{block}}
    end

    # Defines a block of code that will be invoked after every example in the group.
    # The block will be run in the context of the current running example.
    # This means that values defined by `let` and `subject` are available.
    define_example_hook :after_each

    # :ditto:
    macro after(&block)
      after_each {{block}}
    end

    # Defines a block of code that will be invoked around every example in the group.
    # The block will be run in the context of the current running example.
    # This means that values defined by `let` and `subject` are available.
    #
    # The block will execute before the example.
    # An `Example::Procsy` is passed to the block.
    # The `Example::Procsy#run` method should be called to ensure the example runs.
    # More code can run afterwards (in the block).
    define_example_hook :around_each

    # :ditto:
    macro around(&block)
      around_each {{block}}
    end

    # Defines a block of code that will be invoked before every example in the group.
    # The block will be run in the context of the current running example.
    # This means that values defined by `let` and `subject` are available.
    define_example_hook :pre_condition

    # Defines a block of code that will be invoked after every example in the group.
    # The block will be run in the context of the current running example.
    # This means that values defined by `let` and `subject` are available.
    define_example_hook :post_condition
  end
end
