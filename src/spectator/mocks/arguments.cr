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
    class_getter none : AbstractArguments = build

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

    # Returns all named positional and keyword arguments as a named tuple.
    def named : NamedTuple
      {% if Args < NamedTuple %}
        args.merge(kwargs)
      {% else %}
        kwargs
      {% end %}
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
    def ==(other : Arguments)
      positional == other.positional && kwargs == other.kwargs
    end

    # Checks if another set of arguments matches this set of arguments.
    def ===(other : Arguments)
      self_args = args
      other_args = other.args

      case {self_args, other_args}
      when {Tuple, Tuple}      then compare(positional, other.positional, kwargs, other.kwargs)
      when {Tuple, NamedTuple} then compare(kwargs, other.named, positional, other_args, other.splat)
      when {NamedTuple, Tuple} then compare(positional, other.positional, kwargs, other.kwargs)
      else
        self_args === other_args && (!splat || splat === other.splat) && compare_named_tuples(kwargs, other.kwargs)
      end
    end

    private def compare(self_positional : Tuple, other_positional : Tuple, self_kwargs : NamedTuple, other_kwargs : NamedTuple)
      self_positional === other_positional && compare_named_tuples(self_kwargs, other_kwargs)
    end

    private def compare(self_kwargs : NamedTuple, other_named : NamedTuple, self_positional : Tuple, other_args : NamedTuple, other_splat : Tuple?)
      return false unless compare_named_tuples(self_kwargs, other_named)

      i = 0
      other_args.each do |k, v2|
        next if self_kwargs.has_key?(k) # Covered by named arguments.

        v1 = self_positional.fetch(i) { return false }
        i += 1
        return false unless v1 === v2
      end

      other_splat.try &.each do |v2|
        v1 = self_positional.fetch(i) { return false }
        i += 1
        return false unless v1 === v2
      end

      i == self_positional.size
    end

    private def compare_named_tuples(a : NamedTuple, b : NamedTuple)
      a.each do |k, v1|
        v2 = b.fetch(k) { return false }
        return false unless v1 === v2
      end
      true
    end
  end
end
