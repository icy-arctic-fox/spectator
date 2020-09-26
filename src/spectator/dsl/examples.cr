require "../source"
require "./builder"

module Spectator::DSL
  module Examples
    macro define_example(name)
      macro {{name.id}}(what = nil)
        def %test
          \{{yield}}
        end

        %source = ::Spectator::Source.new(__FILE__, __LINE__)
        ::Spectator::DSL::Builder.add_example(
          \{{what.is_a?(StringLiteral) || what.is_a?(NilLiteral) ? what : what.stringify}},
          %source,
          \{{@type.name}}.new
        ) { |example, context| context.as(\{{@type.name}}).%test }
      end
    end

    define_example :example

    define_example :it

    define_example :specify
  end
    macro it(description = nil, _source_file = __FILE__, _source_line = __LINE__, &block)
      {% if block.is_a?(Nop) %}
        {% if description.is_a?(Call) %}
          def %run
            {{description}}
          end
        {% else %}
          {% raise "Unrecognized syntax: `it #{description}` at #{_source_file}:#{_source_line}" %}
        {% end %}
      {% else %}
        def %run
          {{block.body}}
        end
      {% end %}

      %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
      ::Spectator::SpecBuilder.add_example(
        {{description.is_a?(StringLiteral) || description.is_a?(StringInterpolation) || description.is_a?(NilLiteral) ? description : description.stringify}},
        %source,
        {{@type.name}}
      ) { |test| test.as({{@type.name}}).%run }
    end

    macro specify(description = nil, &block)
      it({{description}}) {{block}}
    end

    macro pending(description = nil, _source_file = __FILE__, _source_line = __LINE__, &block)
      {% if block.is_a?(Nop) %}
        {% if description.is_a?(Call) %}
          def %run
            {{description}}
          end
        {% else %}
          {% raise "Unrecognized syntax: `pending #{description}` at #{_source_file}:#{_source_line}" %}
        {% end %}
      {% else %}
        def %run
          {{block.body}}
        end
      {% end %}

      %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
      ::Spectator::SpecBuilder.add_pending_example(
        {{description.is_a?(StringLiteral) || description.is_a?(StringInterpolation) || description.is_a?(NilLiteral) ? description : description.stringify}},
        %source,
        {{@type.name}}
      ) { |test| test.as({{@type.name}}).%run }
    end

    macro skip(description = nil, &block)
      pending({{description}}) {{block}}
    end

    macro xit(description = nil, &block)
      pending({{description}}) {{block}}
    end
end
