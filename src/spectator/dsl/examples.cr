require "../source"
require "../spec_builder"

module Spectator
  module DSL
    macro it(description = nil, &block)
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

      {% if block.is_a?(Nop) %}
        %source = ::Spectator::Source.new({{description.filename}}, line: {{description.line_number}}, end_line: {{description.end_line_number}})
      {% else %}
        %source = ::Spectator::Source.new({{block.filename}}, line: {{block.line_number}}, end_line: {{block.end_line_number}})
      {% end %}
      ::Spectator::SpecBuilder.add_example(
        {{description.is_a?(StringLiteral) || description.is_a?(StringInterpolation) || description.is_a?(NilLiteral) ? description : description.stringify}},
        %source,
        {{@type.name}}
      ) { |test| test.as({{@type.name}}).%run }
    end

    macro specify(description = nil, &block)
      it({{description}}) {{block}}
    end

    macro pending(description = nil, &block)
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

      {% if block.is_a?(Nop) %}
        %source = ::Spectator::Source.new({{description.filename}}, line: {{description.line_number}}, end_line: {{description.end_line_number}})
      {% else %}
        %source = ::Spectator::Source.new({{block.filename}}, line: {{block.line_number}}, end_line: {{block.end_line_number}})
      {% end %}
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
end
