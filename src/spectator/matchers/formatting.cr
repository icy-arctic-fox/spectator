require "../formatters/printer"

module Spectator::Matchers
  module Formatting
    struct DescriptionOf(T)
      def initialize(@value : T)
      end

      def apply(printer : FormattingPrinter)
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
