module Spectator::Core
  enum Status
    Pass
    Fail
    Error
  end

  struct Result
    getter status : Status

    getter! exception : Exception

    def initialize(@status : Status, @exception = nil)
    end

    def self.capture(&) : self
      begin
        yield
        new(:pass)
      rescue ex
        new(:error, ex)
      end
    end
  end
end
