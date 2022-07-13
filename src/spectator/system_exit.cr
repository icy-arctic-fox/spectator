module Spectator
  # Indicates a call to exit the application was performed.
  class SystemExit < Exception
    # Status code passed to the exit call.
    getter status : Int32

    # Creates the exception.
    def initialize(message : String? = nil, cause : Exception? = nil, @status : Int32 = 0)
      super(message, cause)
    end
  end

  # Allow Spectator to exit normally when needed.
  private def self.exit(status = 0) : NoReturn
    ::Crystal::System::Process.exit(status)
  end
end

class Process
  # Replace the typically used exit method with a method that raises.
  # This allows tests to catch attempts to exit the application.
  def self.exit(status = 0) : NoReturn
    raise ::Spectator::SystemExit.new(status: status)
  end
end
