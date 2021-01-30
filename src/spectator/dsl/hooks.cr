require "../source"
require "./builder"

module Spectator::DSL
  # DSL methods for adding custom logic to key times of the spec execution.
  module Hooks
    # Defines a macro to create an example group hook.
    # The *type* indicates when the hook runs and must be a method on `Spectator::DSL::Builder`.
    macro define_example_group_hook(type)
      macro {{type.id}}(&block)
        \{% raise "Missing block for '{{type.id}}' hook" unless block %}
        \{% raise "Cannot use '{{type.id}}' inside of a test block" if @def %}

        def self.\%hook : Nil
          \{{block.body}}
        end

        ::Spectator::DSL::Builder.{{type.id}}(
          ::Spectator::Source.new(\{{block.filename}}, \{{block.line_number}})
        ) { \%hook }
      end
    end

    # Defines a macro to create an example hook.
    # The *type* indicates when the hook runs and must be a method on `Spectator::DSL::Builder`.
    macro define_example_hook(type)
      macro {{type.id}}(&block)
        \{% raise "Missing block for '{{type.id}}' hook" unless block %}
        \{% raise "Block argument count '{{type.id}}' hook must be 0..1" if block.args.size > 1 %}
        \{% raise "Cannot use '{{type.id}}' inside of a test block" if @def %}

        def \%hook(\{{block.args.splat}}) : Nil
          \{{block.body}}
        end

        ::Spectator::DSL::Builder.{{type.id}}(
          ::Spectator::Source.new(\{{block.filename}}, \{{block.line_number}})
        ) do |example|
          example.with_context(\{{@type.name}}) do
            \{% if block.args.empty? %}
              \%hook
            \{% else %}
              \%hook(example)
            \{% end %}
          end
        end
      end
    end

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

    # Defines a block of code that will be invoked after every example in the group.
    # The block will be run in the context of the current running example.
    # This means that values defined by `let` and `subject` are available.
    define_example_hook :after_each

    # Defines a block of code that will be invoked around every example in the group.
    # The block will be run in the context of the current running example.
    # This means that values defined by `let` and `subject` are available.
    #
    # The block will execute before the example.
    # An `Example::Procsy` is passed to the block.
    # The `Example::Procsy#run` method should be called to ensure the example runs.
    # More code can run afterwards (in the block).
    define_example_hook :around_each
  end
end
