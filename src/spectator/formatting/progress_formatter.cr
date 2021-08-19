require "colorize"
require "./formatter"
require "./summary"

module Spectator::Formatting
  # Output formatter that produces a single character for each test as it completes.
  # A '.' indicates a pass, 'F' a failure, 'E' an error, and '*' a skipped or pending test.
  class ProgressFormatter < Formatter
    include Summary

    @pass_char : Colorize::Object(Char) = '.'.colorize(:green)
    @fail_char : Colorize::Object(Char) = 'F'.colorize(:red)
    @error_char : Colorize::Object(Char) = 'E'.colorize(:red)
    @skip_char : Colorize::Object(Char) = '*'.colorize(:yellow)

    # Output stream to write results to.
    private getter io

    # Creates the formatter.
    def initialize(@io : IO = STDOUT)
    end

    # Produces a pass character.
    def example_passed(_notification)
      @pass_char.to_s(@io)
    end

    # Produces a fail character.
    def example_failed(_notification)
      @fail_char.to_s(@io)
    end

    # Produces an error character.
    def example_error(_notification)
      @error_char.to_s(@io)
    end

    # Produces a skip character.
    def example_pending(_notification)
      @skip_char.to_s(@io)
    end

    # Produces a new line after the tests complete.
    def stop
      @io.puts
    end
  end
end
