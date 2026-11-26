require "../matchable"

module Spectator::Matchers::BuiltIn
  struct PredicateMatcher(NT, Args)
    include Matchable

    def initialize(@text : String, @args : Args)
    end

    macro create(method, text, *args)
      %args = Tuple.new({{ args.splat }})
      {% begin %}
        {{ @type.name(generic_args: false) }}(
          { {{ method }}: Nil },
          typeof(%args)
        ).new({{ text }}, %args)
      {% end %}
    end

    def matches?(actual_value)
      {% begin %}
        actual_value.{{ NT.keys.first.id }}(*@args)
      {% end %}
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to " << @text
      print_args(printer)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to " << @text
      print_args(printer)
    end

    private def print_args(printer) : Nil
      return if @args.empty?

      printer << '('
      @args.each_with_index do |arg, i|
        printer << arg
        printer << ", " if i < @args.size - 1
      end
      printer << ')'
    end

    def to_s(io : IO) : Nil
      io << @text
      print_args(io)
    end
  end
end
