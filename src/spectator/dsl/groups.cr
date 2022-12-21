require "../location"
require "./builder"
require "./memoize"
require "./metadata"

module Spectator::DSL
  # DSL methods and macros for creating example groups.
  # This module should be included as a mix-in.
  module Groups
    include Metadata

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

          _spectator_metadata(:metadata, :super, {{tags.splat(", ")}} {{metadata.double_splat}})
          _spectator_metadata(:metadata, :previous_def, \{{tags.splat(", ")}} \{{metadata.double_splat}})

          ::Spectator::DSL::Builder.start_group(
            _spectator_group_name(\{{what}}),
            ::Spectator::Location.new(\{{block.filename}}, \{{block.line_number}}, \{{block.end_line_number}}),
            metadata
          )

          \{{block.body if block}}

          ::Spectator::DSL::Builder.end_group
        end
      end
    end

    # Defines a macro to generate code for an iterative example group.
    # The *name* is the name given to the macro.
    #
    # Default tags can be provided with *tags* and *metadata*.
    # The tags are merged with parent groups.
    # Any items with falsey values from *metadata* remove the corresponding tag.
    #
    # If provided, a block can be used to modify collection that will be iterated.
    # It takes a single argument - the original collection from the user.
    # The modified collection should be returned.
    #
    # TODO: Handle string interpolation in example and group names.
    macro define_iterative_group(name, *tags, **metadata, &block)
      macro {{name.id}}(collection, *tags, count = nil, **metadata, &block)
        \{% raise "Cannot use 'sample' inside of a test block" if @def %}

        class Group\%group < \{{@type.id}}
          _spectator_metadata(:metadata, :super, {{tags.splat(", ")}} {{metadata.double_splat}})
          _spectator_metadata(:metadata, :previous_def, \{{tags.splat(", ")}} \{{metadata.double_splat}})

          def self.\%collection
            \{{collection}}
          end

          {% if block %}
            def self.%mutate({{block.args.splat}})
              {{block.body}}
            end

            def self.\%collection
              %mutate(previous_def)
            end
          {% end %}

          \{% if count %}
            def self.\%collection
              previous_def.first(\{{count}})
            end
          \{% end %}

          ::Spectator::DSL::Builder.start_iterative_group(
            \%collection,
            \{{collection.stringify}},
            [\{{block.args.empty? ? "".id : block.args.map(&.stringify).splat}}] of String,
            ::Spectator::Location.new(\{{block.filename}}, \{{block.line_number}}, \{{block.end_line_number}}),
            metadata
          )

          \{% if block %}
            \{% if block.args.size > 1 %}
              \{% for arg, i in block.args %}
                let(\{{arg}}) do |example|
                  example.group.as(::Spectator::ExampleGroupIteration(typeof(Group\%group.\%collection.first))).item[\{{i}}]
                end
              \{% end %}
            \{% else %}
              let(\{{block.args[0]}}) do |example|
                example.group.as(::Spectator::ExampleGroupIteration(typeof(Group\%group.\%collection.first))).item
              end
            \{% end %}

            \{{block.body}}
          \{% end %}

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
                 what.is_a?(NilLiteral) %}
        {{what}}
      {% elsif what.is_a?(StringInterpolation) %}
        {{@type.name}}.new.eval do
          {{what}}
        rescue e
          "<Failed to evaluate context label - #{e.class}: #{e}>"
        end
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

    define_example_group :xexample_group, skip: "Temporarily skipped with xexample_group"

    define_example_group :xdescribe, skip: "Temporarily skipped with xdescribe"

    define_example_group :xcontext, skip: "Temporarily skipped with xcontext"

    define_example_group :fexample_group, focus: true

    define_example_group :fdescribe, focus: true

    define_example_group :fcontext, focus: true

    # Defines a new iterative example group.
    # This type of group duplicates its contents for each element in *collection*.
    #
    # The first argument is the collection of elements to iterate over.
    #
    # Tags can be specified by adding symbols (keywords) after the first argument.
    # Key-value pairs can also be specified.
    # Any falsey items will remove a previously defined tag.
    #
    # The number of items iterated can be restricted by specifying a *count* argument.
    # The first *count* items will be used if specified, otherwise all items will be used.
    define_iterative_group :sample

    # :ditto:
    define_iterative_group :xsample, skip: "Temporarily skipped with xsample"

    # :ditto:
    define_iterative_group :fsample, focus: true

    # Defines a new iterative example group.
    # This type of group duplicates its contents for each element in *collection*.
    # This is the same as `#sample` except that the items are shuffled.
    # The items are selected with a RNG based on the seed.
    #
    # The first argument is the collection of elements to iterate over.
    #
    # Tags can be specified by adding symbols (keywords) after the first argument.
    # Key-value pairs can also be specified.
    # Any falsey items will remove a previously defined tag.
    #
    # The number of items iterated can be restricted by specifying a *count* argument.
    # The first *count* items will be used if specified, otherwise all items will be used.
    define_iterative_group :random_sample do |collection|
      collection.to_a.shuffle(::Spectator.random)
    end

    # :ditto:
    define_iterative_group :xrandom_sample, skip: "Temporarily skipped with xrandom_sample" do |collection|
      collection.to_a.shuffle(::Spectator.random)
    end

    # :ditto:
    define_iterative_group :frandom_sample, focus: true do |collection|
      collection.to_a.shuffle(::Spectator.random)
    end
  end
end
