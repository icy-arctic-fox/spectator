require "colorize"

module Spectator::Formatters
  # Method for colorizing output.
  module Color
    extend self

    # Symbol in `Colorize` representing success.
    SUCCESS_COLOR = :green

    # Symbol in `Colorize` representing failure.
    FAILURE_COLOR = :red

    # Symbol in `Colorize` representing an error.
    ERROR_COLOR = :magenta

    # Symbol in `Colorize` representing pending or skipped.
    PENDING_COLOR = :yellow

    # Colorizes some text with the success color.
    def success(text)
      text.colorize(SUCCESS_COLOR)
    end

    # Colorizes some text with the failure color.
    def failure(text)
      text.colorize(FAILURE_COLOR)
    end

    # Colorizes some text with the error color.
    def error(text)
      text.colorize(ERROR_COLOR)
    end

    # Colorizes some text with the pending/skipped color.
    def pending(text)
      text.colorize(PENDING_COLOR)
    end
  end
end
