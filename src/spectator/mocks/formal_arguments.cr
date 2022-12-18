require "./abstract_arguments"

module Spectator
  # Arguments passed into a method.
  #
  # *Args* must be a `NamedTuple` type representing the standard arguments.
  # *Splat* must be a `Tuple` type representing the extra positional arguments.
  # *DoubleSplat* must be a `NamedTuple` type representing extra keyword arguments.
  class FormalArguments(Args, Splat, DoubleSplat) < AbstractArguments
    # Positional arguments.
    getter args : Args

    # Additional positional arguments.
    getter splat : Splat

    # Keyword arguments.
    getter kwargs : DoubleSplat

    # Name of the splat argument, if used.
    getter splat_name : Symbol?

    # Creates arguments used in a method call.
    def initialize(@args : Args, @splat_name : Symbol?, @splat : Splat, @kwargs : DoubleSplat)
      {% raise "Positional arguments (generic type Args) must be a NamedTuple" unless Args <= NamedTuple %}
      {% raise "Splat arguments (generic type Splat) must be a Tuple" unless Splat <= Tuple || Splat <= Nil %}
      {% raise "Keyword arguments (generic type DoubleSplat) must be a NamedTuple" unless DoubleSplat <= NamedTuple %}
    end

    # Creates arguments used in a method call.
    def self.new(args : Args, kwargs : DoubleSplat)
      new(args, nil, nil, kwargs)
    end

    # Captures arguments passed to a call.
    def self.build(args = NamedTuple.new, kwargs = NamedTuple.new)
      new(args, nil, nil, kwargs)
    end

    # :ditto:
    def self.build(args : NamedTuple, splat_name : Symbol, splat : Tuple, kwargs = NamedTuple.new)
      new(args, splat_name, splat, kwargs)
    end

    # Instance of empty arguments.
    class_getter none : AbstractArguments = build

    # Returns the positional argument at the specified index.
    def [](index : Int)
      positional[index]
    end

    # Returns the specified named argument.
    def [](arg : Symbol)
      return @args[arg] if @args.has_key?(arg)
      @kwargs[arg]
    end

    # Returns all arguments and splatted arguments as a tuple.
    def positional : Tuple
      if (splat = @splat)
        args.values + splat
      else
        args.values
      end
    end

    # Returns all named positional and keyword arguments as a named tuple.
    def named : NamedTuple
      args.merge(kwargs)
    end

    # Constructs a string representation of the arguments.
    def to_s(io : IO) : Nil
      return io << "(no args)" if args.empty? && ((splat = @splat).nil? || splat.empty?) && kwargs.empty?

      io << '('

      # Add the positional arguments.
      {% if Args < NamedTuple %}
        # Include argument names.
        args.each_with_index do |name, value, i|
          io << ", " if i > 0
          io << name << ": "
          value.inspect(io)
        end
      {% else %}
        args.each_with_index do |arg, i|
          io << ", " if i > 0
          arg.inspect(io)
        end
      {% end %}

      # Add the splat arguments.
      if (splat = @splat) && !splat.empty?
        io << ", " unless args.empty?
        if splat_name = !args.empty? && @splat_name
          io << '*' << splat_name << ": {"
        end
        splat.each_with_index do |arg, i|
          io << ", " if i > 0
          arg.inspect(io)
        end
        io << '}' if splat_name
      end

      # Add the keyword arguments.
      offset = args.size
      offset += splat.size if (splat = @splat)
      kwargs.each_with_index(offset) do |key, value, i|
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
      compare_named_tuples(args, other.args) && compare_tuples(splat, other.splat) && compare_named_tuples(kwargs, other.kwargs)
    end
  end
end
