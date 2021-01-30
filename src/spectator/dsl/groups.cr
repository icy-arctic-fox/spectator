require "../source"
require "./builder"

module Spectator::DSL
  # DSL methods and macros for creating example groups.
  # This module should be included as a mix-in.
  module Groups
    macro define_example_group(name)
      # Defines a new example group.
      # The *what* argument is a name or description of the group.
      #
      # TODO: Handle string interpolation in example and group names.
      macro {{name.id}}(what, *tags, **metadata, &block)
        \{% raise "Cannot use '{{name.id}}' inside of a test block" if @def %}

        class Group\%group < \{{@type.id}}
          _spectator_group_subject(\{{what}})

          def self._spectator_tags
            \{% if tags.empty? && metadata.empty? %}
              super
            \{% else %}
              super.concat({\{{tags.map(&.id.stringify).splat}}}).tap do |tags|
                \{% for k, v in metadata %}
                  cond = begin
                    \{{v}}
                  end
                  if cond
                    tags.add(\{{k.id.stringify}})
                  else
                    tags.remove(\{{k.id.stringify}})
                  end
                \{% end %}
              end
            \{% end %}
          end

          ::Spectator::DSL::Builder.start_group(
            _spectator_group_name(\{{what}}),
            ::Spectator::Source.new(\{{block.filename}}, \{{block.line_number}}),
            _spectator_tags
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
    # This is intended to be used to convert a description from the spec DSL to `Spec::Node#name`.
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
        private def described_class
          {{described_type}}
        end

        private def _spectator_implicit_subject
          {% if described_type < Reference || described_type < Value %}
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

    # TODO: sample, random_sample, and given
  end
end
