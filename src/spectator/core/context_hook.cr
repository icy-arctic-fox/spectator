require "./location_range"

module Spectator::Core
  class ContextHook
    getter! location : LocationRange

    getter! exception : Exception

    @called = Atomic::Flag.new

    def initialize(@location = nil, &@block : ->)
    end

    def initialize(@block : ->)
    end

    def call
      # Ensure the hook is called once.
      called = @called.test_and_set
      # Re-raise previous error if there was one.
      @exception.try { |ex| raise ex }
      # Only call hook if it hasn't been called yet.
      return unless called

      begin
        @block.call
      rescue ex
        @exception = ex
        raise ex
      end
    end
  end
end
