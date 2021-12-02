require "./examples"
require "./groups"
require "./memoize"

module Spectator::DSL
  # DSL methods and macros for shorter syntax.
  module Concise
    # Defines an example and input values in a shorter syntax.
    # The only arguments given to this macro are one or more assignments.
    # The names in the assignments will be available in the example code.
    #
    # If the code block is omitted, then the example is skipped (marked as not implemented).
    #
    # Tags and metadata cannot be used with this macro.
    #
    # ```
    # provided x = 42, y: 123 do
    #   expect(x).to eq(42)
    #   expect(y).to eq(123)
    # end
    # ```
    macro provided(*assignments, it description = nil, **kwargs, &block)
      {% raise "Cannot use 'provided' inside of a test block" if @def %}

      class Given%given < {{@type.id}}
        {% for assignment in assignments %}
          let({{assignment.target}}) { {{assignment.value}} }
        {% end %}
        {% for name, value in kwargs %}
          let({{name}}) { {{value}} }
        {% end %}

        {% if block %}
          {% if description %}
            example {{description}} {{block}}
          {% else %}
            example {{block}}
          {% end %}
        {% else %}
          {% if description %}
            example {{description}} {{block}}
          {% else %}
            example {{assignments.splat.stringify}}
          {% end %}
        {% end %}
      end
    end

    # :ditto:
    @[Deprecated("Use `provided` instead.")]
    macro given(*assignments, **kwargs, &block)
      {% raise "Cannot use 'given' inside of a test block" if @def %}
      provided({{assignments.splat(",")}} {{kwargs.double_splat}}) {{block}}
    end
  end
end
