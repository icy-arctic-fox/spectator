module Spectator
  # Exception raised when `exit` is called and intercepted from a stub.
  class SystemExit < Exception
  end
end
