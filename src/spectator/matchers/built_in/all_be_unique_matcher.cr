require "../formatting"

module Spectator::Matchers::BuiltIn
  struct AllBeUniqueMatcher
    include Formatting

    def match(actual_value : Enumerable(T)) : MatchFailure? forall T
      entries = index_entries(actual_value)
      return if entries.all? { |_, indexes| indexes.size == 1 }

      MatchFailure.new do |printer|
        print_failure_message(printer, actual_value, entries)
      end
    end

    def match(actual_value) : MatchFailure?
      {% raise "`all_be_unique` matcher requires value to be `Enumerable`" %}
    end

    private def index_entries(actual_value : Enumerable(T)) forall T
      entries = {} of T => Array(Int32)
      actual_value.each_with_index do |value, index|
        indexes = entries.put_if_absent(value) { [] of Int32 }
        indexes << index
      end
      entries
    end

    private def print_failure_message(printer : Formatters::Printer, actual_value, entries) : Nil
      printer << "Expected: " << description_of(actual_value) << EOL
      printer << "to have unique items" << EOL
      entries.each do |value, indexes|
        next if indexes.size == 1
        printer << EOL << description_of(value) << " appears at indices: " << description_of(indexes)
      end
    end
  end
end
