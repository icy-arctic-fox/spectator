require "../location"
require "./builder"
require "./tags"
require "./memoize"

module Spectator::DSL
  # DSL methods and macros for creating example groups.
  # This module should be included as a mix-in.
  module Groups
    include Tags

    # Defines a macro to generate code for an example group.
    # The *name* is the name given to the macro.
    #
    # Default tags can be provided with *tags* and *metadata*.
    # The tags are merged with parent groups.
    # Any items with falsey values from *metadata* remove the corresponding tag.
    macro define_example_group(name, *tags, **metadata)
      # Defines a new example group.
      # The *what* argument is a name or description of the group.
      #
      # The first argument names the example (test).
      # Typically, this specifies what is being tested.
      # This argument is also used as the subject.
      # When it is a type name, it becomes an explicit, which overrides any previous subjects.
      # Otherwise it becomes an implicit subject, which doesn't override explicitly defined subjects.
      #
      # Tags can be specified by adding symbols (keywords) after the first argument.
      # Key-value pairs can also be specified.
      # Any falsey items will remove a previously defined tag.
      #
      # TODO: Handle string interpolation in example and group names.
      macro {{name.id}}(what, *tags, **metadata, &block)
        \{% raise "Cannot use '{{name.id}}' inside of a test block" if @def %}

        class Group\%group < \{{@type.id}}
          _spectator_group_subject(\{{what}})

          _spectator_tags(:tags, :super, {{tags.splat(", ")}} {{metadata.double_splat}})
          _spectator_tags(:tags, :previous_def, \{{tags.splat(", ")}} \{{metadata.double_splat}})

          ::Spectator::DSL::Builder.start_group(
            _spectator_group_name(\{{what}}),
            ::Spectator::Location.new(\{{block.filename}}, \{{block.line_number}}),
            tags
          )

          \{{block.body}}

          ::Spectator::DSL::Builder.end_group
        end
      end
    end

    # Inserts the correct representation of a group's name.
    # If *what* appears to be a type name, it will be symbolized.
    # If it's a string, then it is dropped in as-is.
    # For anything else, it is stringified.
    # This is intended to be used to convert a description from the spec DSL to `Node#name`.
    private macro _spectator_group_name(what)
      {% if (what.is_a?(Generic) ||
              what.is_a?(Path) ||
              what.is_a?(TypeNode) ||
              what.is_a?(Union)) &&
              what.resolve?.is_a?(TypeNode) %}
        {{what.symbolize}}
      {% elsif what.is_a?(StringLiteral) ||
                 what.is_a?(StringInterpolation) ||
                 what.is_a?(NilLiteral) %}
        {{what}}
      {% else %}
        {{what.stringify}}
      {% end %}
    end

    # Defines the implicit subject for the test context.
    # If *what* is a type, then the `described_class` method will be defined.
    # Additionally, the implicit subject is set to an instance of *what* if it's not a module.
    #
    # There is no common macro type that has the `#resolve?` method.
    # Also, `#responds_to?` can't be used in macros.
    # So the large if statement in this macro is used to look for type signatures.
    private macro _spectator_group_subject(what)
      {% if (what.is_a?(Generic) ||
              what.is_a?(Path) ||
              what.is_a?(TypeNode) ||
              what.is_a?(Union)) &&
              (described_type = what.resolve?).is_a?(TypeNode) %}
        private macro described_class
          {{what}}
        end

        subject do
          {% if described_type.class? || described_type.struct? %}
            described_class.new
          {% else %}
            described_class
          {% end %}
        end
      {% else %}
        private def _spectator_implicit_subject
          {{what}}
        end
      {% end %}
    end

    define_example_group :example_group

    define_example_group :describe

    define_example_group :context

    define_example_group :xexample_group, :pending

    define_example_group :xdescribe, :pending

    define_example_group :xcontext, :pending

    # TODO: sample, random_sample, and given
  end
end
