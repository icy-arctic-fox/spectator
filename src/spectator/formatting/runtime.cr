module Spectator::Formatting
  # Produces a stringified time span for the runtime.
  private struct Runtime
    # Creates the runtime instance.
    def initialize(@runtime : Time::Span)
    end

    # Appends the runtime to the output.
    # The text will be formatted as follows,
    # depending on the length of time:
    # ```text
    # Finished in ## microseconds
    # Finished in ## milliseconds
    # Finished in ## seconds
    # Finished in #:##
    # Finished in #:##:##
    # Finished in # days #:##:##
    # ```
    def to_s(io)
      io << "Finished in "
      io << human_time(@runtime)
    end

    # Provides a more human-friendly formatting for a time span.
    # This produces a string with the minimum of
    # microseconds, milliseconds, seconds, minutes, hours, or days.
    private def human_time(span)
      millis = span.total_milliseconds
      return "#{(millis * 1000).round.to_i} microseconds" if millis < 1

      seconds = span.total_seconds
      return "#{millis.round(2)} milliseconds" if seconds < 1
      return "#{seconds.round(2)} seconds" if seconds < 60

      int_seconds = seconds.to_i
      minutes = int_seconds / 60
      int_seconds %= 60
      return sprintf("%i:%02i", minutes, int_seconds) if minutes < 60

      hours = minutes / 60
      minutes %= 60
      return sprintf("%i:%02i:%02i", hours, minutes, int_seconds) if hours < 24

      days = hours / 24
      hours %= 24
      return sprintf("%i days %i:%02i:%02i", days, hours, minutes, int_seconds)
    end
  end
end
