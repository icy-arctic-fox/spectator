require "../source"
require "../spec_builder"

module Spectator
  module DSL
    macro it(what, _source_file = __FILE__, _source_line = __LINE__, &block)
      {% if block.is_a?(Nop) %}
        {% if what.is_a?(Call) %}
          def %run
            {{what}}
          end
        {% else %}
          {% raise "Unrecognized syntax: `it #{what}` at #{_source_file}:#{_source_line}" %}
        {% end %}
      {% else %}
        def %run
          {{block.body}}
        end
      {% end %}

      %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
      ::Spectator::SpecBuilder.add_example(
        {{what.is_a?(StringLiteral) ? what : what.stringify}},
        %source,
        {{@type.name}}
      ) { |test| test.as({{@type.name}}).%run }
    end
  end
end
