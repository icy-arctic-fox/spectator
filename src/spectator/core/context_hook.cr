require "./location_range"

module Spectator::Core
  class ContextHook
    enum Position
      Before
      After
    end

    getter location : LocationRange?

    getter exception : Exception?

    getter position : Position

    {% if compare_versions(Crystal::VERSION, "1.13.0") < 0 %}
      @called = Atomic::Flag.new
    {% else %}
      @called = Atomic(Bool).new(false)
    {% end %}

    def initialize(@position, @location = nil, &@block : ->)
    end

    def call
      # Ensure the hook is called once.
      called = mark_called
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
      in .before? then io << "before context"
      in .after?  then io << "after context"
      end

      if location = @location
        io << " @ " << location
      end
      io << " 0x"
      object_id.to_s(io, 16)
      io << '>'
    end

    # Marks the hook as having been called.
    # Returns true on the first call and false on subsequent calls.
    private def mark_called : Bool
      {% if compare_versions(Crystal::VERSION, "1.13.0") < 0 %}
        @called.test_and_set
      {% else %}
        !@called.swap(true, :relaxed)
      {% end %}
    end
  end
end
