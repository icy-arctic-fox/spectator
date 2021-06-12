require "./examples"
require "./groups"
require "./memoize"

module Spectator::DSL
  # DSL methods and macros for shorter syntax.
  module Concise
    # Defines an example and input values in a shorter syntax.
    # The only arguments given to this macro are one or more assignments.
    # The names in the assigments will be available in the example code.
    #
    # If the code block is omitted, then the example is skipped (marked as not implemented).
    #
    # Tags and metadata cannot be used with this macro.
    #
    # ```
    # given x = 42 do
    #   expect(x).to eq(42)
    # end
    # ```
    macro provided(*assignments, &block)
      {% raise "Cannot use 'provided' inside of a test block" if @def %}

      class Given%given < {{@type.id}}
        {% for assignment in assignments %}
          let({{assignment.target}}) { {{assignment.value}} }
        {% end %}

        {% if block %}
          example {{block}}
        {% else %}
          example {{assignments.splat.stringify}}
        {% end %}
      end
    end

    # :ditto:
    @[Deprecated("Use `provided` instead.")]
    macro given(*assignments, &block)
      {% raise "Cannot use 'given' inside of a test block" if @def %}
      provided({{assignments.splat}}) {{block}}
    end
  end
end
