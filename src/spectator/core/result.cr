module Spectator::Core
  enum Status
    Pass
    Fail
    Error
  end

  struct Result
    getter status : Status

    getter! exception : Exception

    def initialize(@status, @exception = nil)
    end
  end
end
