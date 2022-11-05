module Spectator::Formatting::Components
  # Presents a human readable time span.
  struct Runtime
    # Creates the component.
    def initialize(@span : Time::Span)
    end

    # Appends the elapsed time to the output.
    # The text will be formatted as follows, depending on the magnitude:
    # ```text
    # ## microseconds
    # ## milliseconds
    # ## seconds
    # #:##
    # #:##:##
    # # days #:##:##
    # ```
    def to_s(io : IO) : Nil
      millis = @span.total_milliseconds
      return format_micro(io, millis * 1000) if millis < 1

      seconds = @span.total_seconds
      return format_millis(io, millis) if seconds < 1
      return format_seconds(io, seconds) if seconds < 60

      minutes, seconds = seconds.divmod(60)
      return format_minutes(io, minutes, seconds) if minutes < 60

      hours, minutes = minutes.divmod(60)
      return format_hours(io, hours, minutes, seconds) if hours < 24

      days, hours = hours.divmod(24)
      format_days(io, days, hours, minutes, seconds)
    end

    # Formats for microseconds.
    private def format_micro(io, micros)
      io << micros.round.to_i << " microseconds"
    end

    # Formats for milliseconds.
    private def format_millis(io, millis)
      io << millis.round(2) << " milliseconds"
    end

    # Formats for seconds.
    private def format_seconds(io, seconds)
      io << seconds.round(2) << " seconds"
    end

    # Formats for minutes.
    private def format_minutes(io, minutes, seconds)
      io.printf("%i:%02i", minutes, seconds)
    end

    # Formats for hours.
    private def format_hours(io, hours, minutes, seconds)
      io.printf("%i:%02i:%02i", hours, minutes, seconds)
    end

    # Formats for days.
    private def format_days(io, days, hours, minutes, seconds)
      io.printf("%i days %i:%02i:%02i", days, hours, minutes, seconds)
    end
  end
end
