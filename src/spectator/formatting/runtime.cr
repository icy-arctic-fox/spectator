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
      io << HumanTime.new(@runtime)
    end
  end
end
