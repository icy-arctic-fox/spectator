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

    struct InspectValue(T)
      include Formatters::Printable

      def initialize(@value : T)
      end

      def print(printer : Formatters::Printer) : Nil
        printer.inspect_value(@value)
      end
    end

    def inspect_value(value)
      InspectValue.new(value)
    end

    struct InspectString
      include Formatters::Printable

      def initialize(@value : String, @property : Formatters::StringProperty = :object_id)
      end

      def print(printer : Formatters::Printer) : Nil
        printer.inspect_string(@value, @property)
      end
    end

    def string_size(value)
      InspectString.new(value.to_s, :size)
    end

    def string_bytesize(value)
      InspectString.new(value.to_s, :bytesize)
    end

    struct MethodName
      include Formatters::Printable

      def initialize(@name : String)
      end

      def print(printer : Formatters::Printer) : Nil
        printer.id(@name)
      end
    end

    def method_name(name)
      MethodName.new(name.to_s)
    end
  end
end
