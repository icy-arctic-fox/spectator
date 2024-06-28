require "./item"
require "./location_range"
require "./result"

module Spectator::Core
  # Information about a test case and functionality for running it.
  class Example < Item
    # Creates a new example.
    #
    # The *description* can be a string, nil, or any other object.
    # When it is a string or nil, it will be stored as-is.
    # Any other types will be converted to a string by calling `#inspect` on it.
    def initialize(description = nil, location : LocationRange? = nil, &@block : Example -> Nil)
      super(description, location)
    end

    # Runs the example.
    def run : Result
      Result.capture do
        if context = parent?
          context.with_hooks(self) do
            @block.call(self)
          end
        else
          @block.call(self)
        end
      end
    end

    # Constructs a string representation of the example.
    # The description will be used if it is set, otherwise the example will be anonymous.
    def to_s(io : IO) : Nil
      if description = @description
        io << description
      else
        io << "<Anonymous Example>"
      end
    end

    def inspect(io : IO) : Nil
      inspect(io) { }
    end

    protected def inspect(io : IO, & : IO ->) : Nil
      io << "#<" << self.class << ' '
      if description = @description
        io << '"' << description << '"'
      else
        io << "Anonymous Example"
      end
      if location = @location
        io << " @ " << location
      end
      io << " 0x"
      object_id.to_s(io, 16)
      yield io
      io << '>'
    end

    def to_proc(&block : Example ->)
      Procsy.new(self, &block)
    end

    def to_proc
      Procsy.new(self)
    end

    struct Procsy
      @proc : self ->

      def initialize(@example : Example, &@proc : self ->)
      end

      def initialize(@example : Example)
        @proc = ->@example.run
      end

      def run
        @proc.call(@example)
      end

      forward_missing_to @example
      delegate to_s, to: @example

      def inspect(io : IO) : Nil
        @example.inspect(io, &.<< " Procsy")
      end
    end
  end
end
