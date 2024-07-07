require "./location_range"

module Spectator::Core
  class ContextHook
    enum Position
      Before
      After
    end

    getter! location : LocationRange

    getter! exception : Exception

    getter position : Position

    @called = Atomic::Flag.new

    def initialize(@position, @location = nil, &@block : ->)
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

    def inspect(io : IO) : Nil
      io << "#<" << self.class << ' '

      case @position
      in Position::Before then io << "before context"
      in Position::After  then io << "after context"
      end

      if location = @location
        io << " @ " << location
      end
      io << " 0x"
      object_id.to_s(io, 16)
      io << '>'
    end
  end
end
