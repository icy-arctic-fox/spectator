module Spectator::Formatting
  # Produces a stringified failure or error message.
  private struct FailureMessage
    # Creates the failure message.
    def initialize(@result : FailedResult)
    end

    # Appends the message to the output.
    def to_s(io)
      io << @result.call(Label)
      io << @result.error
    end

    # Creates a colorized version of the message.
    def self.color(result)
      result.call(Color) { |result| new(result) }
    end

    # Interface for `Result#call` to invoke.
    # This is used to get the correct prefix for failures and errors.
    private module Label
      extend self

      # Returns the prefix for a failure message.
      def failure
        "Failure: "
      end

      # Returns the prefix for an error message.
      def error
        "Error: "
      end
    end
  end
end
