require "../source"
require "../spec_builder"

module Spectator
  module DSL
    macro it(description, _source_file = __FILE__, _source_line = __LINE__, &block)
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
        {{description.is_a?(StringLiteral) ? description : description.stringify}},
        %source,
        {{@type.name}}
      ) { |test| test.as({{@type.name}}).%run }
    end

    macro specify(description, &block)
      it({{description}}) {{block}}
    end

    macro pending(description, _source_file = __FILE__, _source_line = __LINE__, &block)
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
        {{description.is_a?(StringLiteral) ? description : description.stringify}},
        %source,
        {{@type.name}}
      ) { |test| test.as({{@type.name}}).%run }
    end

    macro skip(description, &block)
      pending({{description}}) {{block}}
    end

    macro xit(description, &block)
      pending({{description}}) {{block}}
    end
  end
end
