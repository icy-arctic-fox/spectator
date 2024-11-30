require "../formatters/printer"

module Spectator::Matchers
  module Formatting
    struct DescriptionOf(T)
      include Formatters::Printable

      def initialize(@value : T)
      end

      def print(printer : Formatters::Printer) : Nil
        case value = @value
        when Class then printer.type(value)
        else            printer.value(value)
        end
      end
    end

    def description_of(value)
      DescriptionOf.new(value)
    end

    def description_of(matchable : Matchable)
      matchable.description
    end
  end
end
