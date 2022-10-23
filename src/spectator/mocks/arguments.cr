require "./abstract_arguments"

module Spectator
  # Arguments used in a method call.
  #
  # Can also be used to match arguments.
  # *Positional* must be a `Tuple` or `NamedTuple` type representing the standard arguments.
  # *Splat* must be a `Tuple` type representing the extra positional arguments.
  # *DoubleSplat* must be a `NamedTuple` type representing extra keyword arguments.
  class Arguments(Positional, Splat, DoubleSplat) < AbstractArguments
    # Positional arguments.
    getter positional : Positional

    # Additional positional arguments.
    getter extra : Splat

    # Keyword arguments.
    getter kwargs : DoubleSplat

    # Name of the splat argument, if used.
    getter splat_name : Symbol?

    # Creates arguments used in a method call.
    def initialize(@positional : Positional, @splat_name : Symbol?, @extra : Splat, @kwargs : DoubleSplat)
    end

    # Creates arguments used in a method call.
    def self.new(positional : Positional, kwargs : DoubleSplat)
      new(positional, nil, nil, kwargs)
    end

    # Instance of empty arguments.
    class_getter none : AbstractArguments = capture

    # Returns unconstrained arguments.
    def self.any : AbstractArguments?
      nil.as(AbstractArguments?)
    end

    # Captures arguments passed to a call.
    def self.build(positional = Tuple.new, kwargs = NamedTuple.new)
      new(positional, nil, nil, kwargs)
    end

    # :ditto:
    def self.build(positional : NamedTuple, splat_name : Symbol, extra : Tuple, kwargs = NamedTuple.new)
      new(positional, splat_name, extra, kwargs)
    end

    # Friendlier constructor for capturing arguments.
    def self.capture(*args, **kwargs)
      new(args, nil, nil, kwargs)
    end

    # Returns the positional argument at the specified index.
    def [](index : Int)
      {% if Positional < NamedTuple %}
        @positional.values[index]
      {% else %}
        @positional[index]
      {% end %}
    end

    # Returns the specified named argument.
    def [](arg : Symbol)
      {% if Positional < NamedTuple %}
        return @positional[arg] if @positional.has_key?(arg)
      {% end %}
      @kwargs[arg]
    end

    # Constructs a string representation of the arguments.
    def to_s(io : IO) : Nil
      return io << "(no args)" if positional.empty? && ((extra = @extra).nil? || extra.empty?) && kwargs.empty?

      io << '('

      # Add the positional arguments.
      {% if Positional < NamedTuple %}
        # Include argument names.
        positional.each_with_index do |name, value, i|
          io << ", " if i > 0
          io << name << ": "
          value.inspect(io)
        end
      {% else %}
        positional.each_with_index do |arg, i|
          io << ", " if i > 0
          arg.inspect(io)
        end
      {% end %}

      # Add the splat arguments.
      if (extra = @extra) && !extra.empty?
        if splat = @splat_name
          io << splat << ": {"
        end
        io << ", " unless positional.empty?
        extra.each_with_index do |arg, i|
          io << ", " if i > 0
          arg.inspect(io)
        end
        io << '}' if @splat_name
        io << ", " unless kwargs.empty?
      end

      # Add the keyword arguments.
      offset = positional.size
      offset += extra.size if (extra = @extra)
      kwargs.each_with_index(offset) do |name, value, i|
        io << ", " if i > 0
        io << name << ": "
        value.inspect(io)
      end

      io << ')'
    end

    # Checks if this set of arguments and another are equal.
    def ==(other : Arguments)
      ordered = simplify_positional
      other_ordered = other.simplify_positional
      ordered == other_ordered && kwargs == other.kwargs
    end

    # Checks if another set of arguments matches this set of arguments.
    def ===(other : Arguments)
      {% if Positional < NamedTuple %}
        if (other_positional = other.positional).is_a?(NamedTuple)
          positional.each do |k, v|
            return false unless other_positional.has_key?(k)
            return false unless v === other_positional[k]
          end
        else
          return false if positional.size != other_positional
          positional.each_with_index do |k, v, i|
            return false unless v === other_positional.unsafe_fetch(i)
          end
        end
      {% else %}
        return false unless positional === other.simplify_positional
      {% end %}

      if extra = @extra
        return false unless extra === other.extra
      end

      kwargs.each do |k, v|
        return false unless other.kwargs.has_key?(k)
        return false unless v === other.kwargs[k]
      end

      true
    end

    protected def simplify_positional
      if (extra = @extra)
        {% if Positional < NamedTuple %}positional.values{% else %}positional{% end %} + extra
      else
        {% if Positional < NamedTuple %}positional.values{% else %}positional{% end %}
      end
    end
  end
end
