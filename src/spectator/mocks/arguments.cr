module Spectator
  # Arguments used in a method call.
  #
  # Can also be used to match arguments.
  # *T* must be a `Tuple` type representing the positional arguments.
  # *NT* must be a `NamedTuple` type representing the keyword arguments.
  class Arguments(T, NT)
    # Positional arguments.
    getter args : T

    # Keyword arguments.
    getter kwargs : NT

    # Creates arguments used in a method call.
    def initialize(@args : T, @kwargs : NT)
    end

    # Constructs an instance from literal arguments.
    def self.capture(*args, **kwargs) : self
      new(args, kwargs)
    end

    # Constructs a string representation of the arguments.
    def to_s(io : IO) : Nil
      io << '('

      # Add the positional arguments.
      args.each_with_index do |arg, i|
        io << ", " if i > 0
        arg.inspect(io)
      end

      # Add the keyword arguments.
      size = args.size + kwargs.size
      kwargs.each_with_index(args.size) do |k, v, i|
        io << ", " if 0 < i < size
        io << k << ": "
        v.inspect(io)
      end

      io << ')'
    end

    # Checks if this set of arguments and another are equal.
    def ==(other : Arguments)
      args == other.args && kwargs == other.kwargs
    end

    # Checks if another set of arguments matches this set of arguments.
    def ===(other : Arguments)
      args === other.args && named_tuples_match?(kwargs, other.kwargs)
    end

    # Checks if two named tuples match.
    #
    # Uses case equality (`===`) on every key-value pair.
    # NamedTuple doesn't have a `===` operator, even though Tuple does.
    private def named_tuples_match?(a : NamedTuple, b : NamedTuple)
      return false if a.size != b.size

      a.each do |k, v|
        return false unless b.has_key?(k)
        return false unless v === b[k]
      end

      true
    end
  end
end
