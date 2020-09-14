require "../source"
require "./builder"

module Spectator::DSL
  module Examples
    macro example(what = nil, *, _source_file = __FILE__, _source_line = __LINE__, &block)
      def %test
        {{block.body}}
      end

      %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
      ::Spectator::DSL::Builder.add_example(
        {{what.is_a?(StringLiteral | NilLiteral) ? what : what.stringify}},
        %source,
        {{@type.name}}.new
      ) { |example, context| context.as({{@type.name}}).%test }
    end

    macro it(what = nil, *, _source_file = __FILE__, _source_line = __LINE__, &block)
      example({{what}}, _source_file: {{_source_file}}, _source_line: {{_source_line}}) {{block}}
    end

    macro specify(what = nil, *, _source_file = __FILE__, _source_line = __LINE__, &block)
      example({{what}}, _source_file: {{_source_file}}, _source_line: {{_source_line}}) {{block}}
    end
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
        {{description.is_a?(StringLiteral) || description.is_a?(NilLiteral) ? description : description.stringify}},
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
        {{description.is_a?(StringLiteral) || description.is_a?(NilLiteral) ? description : description.stringify}},
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
