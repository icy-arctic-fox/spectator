require "colorize"

module Spectator::Formatting
  # Method for colorizing output.
  module Color
    extend self

    # Symbols in `Colorize` representing result types and formatting types.
    private COLORS = {
      success: :green,
      failure: :red,
      error:   :magenta,
      pending: :yellow,
      comment: :cyan,
    }

    # Colorizes some text with the success color.
    def success(text)
      text.colorize(COLORS[:success])
    end

    # Colorizes some text with the failure color.
    def failure(text)
      text.colorize(COLORS[:failure])
    end

    # Colorizes some text with the error color.
    def error(text)
      text.colorize(COLORS[:error])
    end

    # Colorizes some text with the pending/skipped color.
    def pending(text)
      text.colorize(COLORS[:pending])
    end

    # Colorizes some text with the comment color.
    def comment(text)
      text.colorize(COLORS[:comment])
    end
  end
end
