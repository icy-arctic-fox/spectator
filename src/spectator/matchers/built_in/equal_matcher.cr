require "../formatting"

module Spectator::Matchers::BuiltIn
  struct EqualMatcher(T)
    include Formatting

    def description
      "be equal to #{@expected_value}"
    end

    def initialize(@expected_value : T)
    end

    def match(actual_value) : MatchFailure?
      expected_value = @expected_value

      if actual_value.is_a?(String) && expected_value.is_a?(String)
        match_strings(actual_value, expected_value)
      else
        return if actual_value == expected_value

        MatchFailure.new do |printer|
          printer << "Expected: " << description_of(expected_value) << EOL
          printer << "     got: " << description_of(actual_value)
        end
      end
    end

    private def match_strings(actual_value : String, expected_value : String) : MatchFailure?
      formatter = if actual_value != expected_value
                    ->description_of(String)
                  elsif actual_value.size != expected_value.size
                    ->string_size(String)
                  elsif actual_value.bytesize != expected_value.bytesize
                    ->string_bytesize(String)
                  else
                    return # Matched
                  end
      MatchFailure.new do |printer|
        printer << "Expected: " << formatter.call(expected_value) << EOL
        printer << "     got: " << formatter.call(actual_value)
      end
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "    Expected: " << description_of(actual_value) << EOL
      printer << "not to equal: " << description_of(@expected_value)
    end
  end
end
