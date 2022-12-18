require "./abstract_arguments"

module Spectator
  # Arguments used in a method call.
  #
  # Can also be used to match arguments.
  # *Args* must be a `Tuple` representing the standard arguments.
  # *KWArgs* must be a `NamedTuple` type representing extra keyword arguments.
  class Arguments(Args, KWArgs) < AbstractArguments
    # Positional arguments.
    getter args : Args

    # Keyword arguments.
    getter kwargs : KWArgs

    # Creates arguments used in a method call.
    def initialize(@args : Args, @kwargs : KWArgs)
      {% raise "Positional arguments (generic type Args) must be a Tuple" unless Args <= Tuple %}
      {% raise "Keyword arguments (generic type KWArgs) must be a NamedTuple" unless KWArgs <= NamedTuple %}
    end

    # Instance of empty arguments.
    class_getter none : AbstractArguments = capture

    # Returns unconstrained arguments.
    def self.any : AbstractArguments?
      nil.as(AbstractArguments?)
    end

    # Friendlier constructor for capturing arguments.
    def self.capture(*args, **kwargs)
      new(args, kwargs)
    end

    # Returns the positional argument at the specified index.
    def [](index : Int)
      args[index]
    end

    # Returns the specified named argument.
    def [](arg : Symbol)
      @kwargs[arg]
    end

    # Returns all arguments and splatted arguments as a tuple.
    def positional : Tuple
      args
    end

    # Returns all named positional and keyword arguments as a named tuple.
    def named : NamedTuple
      kwargs
    end

    # Constructs a string representation of the arguments.
    def to_s(io : IO) : Nil
      return io << "(no args)" if args.empty? && kwargs.empty?

      io << '('

      # Add the positional arguments.
      args.each_with_index do |arg, i|
        io << ", " if i > 0
        arg.inspect(io)
      end

      # Add the keyword arguments.
      kwargs.each_with_index(args.size) do |key, value, i|
        io << ", " if i > 0
        io << key << ": "
        value.inspect(io)
      end

      io << ')'
    end

    # Checks if this set of arguments and another are equal.
    def ==(other : AbstractArguments)
      positional == other.positional && kwargs == other.kwargs
    end

    # Checks if another set of arguments matches this set of arguments.
    def ===(other : Arguments)
      compare_tuples(positional, other.positional) && compare_named_tuples(kwargs, other.kwargs)
    end

    # :ditto:
    def ===(other : FormalArguments)
      return false unless compare_named_tuples(kwargs, other.named)

      i = 0
      other.args.each do |k, v2|
        break if i >= positional.size
        next if kwargs.has_key?(k) # Covered by named arguments.

        v1 = positional[i]
        i += 1
        return false unless compare_values(v1, v2)
      end

      other.splat.try &.each do |v2|
        v1 = positional.fetch(i) { return false }
        i += 1
        return false unless compare_values(v1, v2)
      end

      i == positional.size
    end
  end
end
