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
      @printer.value(value)
    end

    def description_of(value : T.class) : Nil forall T
      @printer.type(value)
    end

    def description_of(matchable : Matchable) : Nil
      @printer << matchable.description
    end
  end
end
