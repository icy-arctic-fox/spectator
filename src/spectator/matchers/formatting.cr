require "../formatters/printer"

module Spectator::Matchers
  module Formatting
    def description_of(value)
      # TODO: Actually format the value.
      value.inspect
    end

    def description_of(matchable : Matchable)
      matchable.description
    end
  end

  struct FormattingPrinter
    forward_missing_to @printer

    def initialize(@printer : Formatters::Printer)
    end

    def description_of(value) : Nil
      @printer.print_value do |io|
        value.inspect(io)
      end
    end

    def description_of(value : T.class) : Nil forall T
      @printer.print_type do |io|
        value.inspect(io)
      end
    end

    def description_of(matchable : Matchable) : Nil
      @printer.print do |io|
        io << matchable.description
      end
    end
  end
end
