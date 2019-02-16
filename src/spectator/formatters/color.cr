module Spectator::Formatters
  # Mix-in that provides methods for colorizing output.
  module Color
    # Symbol in `Colorize` representing success.
    SUCCESS_COLOR = :green

    # Symbol in `Colorize` representing failure.
    FAILURE_COLOR = :red

    # Symbol in `Colorize` representing an error.
    ERROR_COLOR = :magenta

    # Symbol in `Colorize` representing pending or skipped.
    PENDING_COLOR = :yellow

    # Colorizes some text with the success color.
    private def success(text)
      text.colorize(SUCCESS_COLOR)
    end

    # Colorizes some text with the failure color.
    private def failure(text)
      text.colorize(FAILURE_COLOR)
    end

    # Colorizes some text with the error color.
    private def error(text)
      text.colorize(ERROR_COLOR)
    end

    # Colorizes some text with the pending/skipped color.
    private def pending(text)
      text.colorize(PENDING_COLOR)
    end
  end
end
