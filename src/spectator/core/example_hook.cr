require "./location_range"

module Spectator::Core
  class ExampleHook(T)
    enum Position
      Before
      After
      Around
    end

    getter! location : LocationRange

    getter! exception : Exception

    getter position : Position

    def initialize(@position : Position, @location = nil, &@block : T ->)
    end

    def initialize(@position : Position, @block : T ->)
    end

    def call(example : T)
      # Re-raise previous error if there was one.
      @exception.try { |ex| raise ex }

      begin
        @block.call(example)
      rescue ex
        @exception = ex
        raise ex
      end
    end

    def inspect(io : IO) : Nil
      io << "#<" << self.class << ' '

      case @position
      in .before? then io << "before example"
      in .after?  then io << "after example"
      in .around? then io << "around example"
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
