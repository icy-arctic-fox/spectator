require "./abstract_arguments"

module Spectator
  # Arguments used in a method call.
  #
  # Can also be used to match arguments.
  # *Args* must be a `Tuple` or `NamedTuple` type representing the standard arguments.
  # *Splat* must be a `Tuple` type representing the extra positional arguments.
  # *DoubleSplat* must be a `NamedTuple` type representing extra keyword arguments.
  class Arguments(Args, Splat, DoubleSplat) < AbstractArguments
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
    end

    # Creates arguments used in a method call.
    def self.new(args : Args, kwargs : DoubleSplat)
      new(args, nil, nil, kwargs)
    end

    # Instance of empty arguments.
    class_getter none : AbstractArguments = capture

    # Returns unconstrained arguments.
    def self.any : AbstractArguments?
      nil.as(AbstractArguments?)
    end

    # Captures arguments passed to a call.
    def self.build(args = Tuple.new, kwargs = NamedTuple.new)
      new(args, nil, nil, kwargs)
    end

    # :ditto:
    def self.build(args : NamedTuple, splat_name : Symbol, splat : Tuple, kwargs = NamedTuple.new)
      new(args, splat_name, splat, kwargs)
    end

    # Friendlier constructor for capturing arguments.
    def self.capture(*args, **kwargs)
      new(args, nil, nil, kwargs)
    end

    # Returns the positional argument at the specified index.
    def [](index : Int)
      positional[index]
    end

    # Returns the specified named argument.
    def [](arg : Symbol)
      {% if Args < NamedTuple %}
        return @args[arg] if @args.has_key?(arg)
      {% end %}
      @kwargs[arg]
    end

    # Returns all arguments and splatted arguments as a tuple.
    def positional : Tuple
      if (splat = @splat)
        {% if Args < NamedTuple %}args.values{% else %}args{% end %} + splat
      else
        {% if Args < NamedTuple %}args.values{% else %}args{% end %}
      end
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
        if name = @splat_name
          io << '*' << name << ": {"
        end
        splat.each_with_index do |arg, i|
          io << ", " if i > 0
          arg.inspect(io)
        end
        io << '}' if @splat_name
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
    def ==(other : Arguments)
      positional == other.positional && kwargs == other.kwargs
    end

    # Checks if another set of arguments matches this set of arguments.
    def ===(other : Arguments)
      {% if Args < NamedTuple %}
        if (other_args = other.args).is_a?(NamedTuple)
          args.each do |k, v|
            return false unless other_args.has_key?(k)
            return false unless v === other_args[k]
          end
        else
          return false if args.size != other_args
          args.each_with_index do |k, v, i|
            return false unless v === other_args.unsafe_fetch(i)
          end
        end
      {% else %}
        return false unless args === other.positional
      {% end %}

      if splat = @splat
        return false unless splat === other.splat
      end

      kwargs.each do |k, v|
        return false unless other.kwargs.has_key?(k)
        return false unless v === other.kwargs[k]
      end

      true
    end
  end
end
