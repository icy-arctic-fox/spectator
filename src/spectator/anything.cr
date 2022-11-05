module Spectator
  # Type dedicated to matching everything.
  # This is intended to be used as a value to compare against when the value doesn't matter.
  # Can be used like so:
  # ```
  # anything = Spectator::Anything.new
  # expect("foo").to match(anything)
  # ```
  struct Anything
    # Always returns true.
    def ===(other)
      true
    end

    # Displays "anything".
    def to_s(io : IO) : Nil
      io << "anything"
    end

    # Displays "<anything>".
    def inspect(io : IO) : Nil
      io << "<anything>"
    end
  end
end
