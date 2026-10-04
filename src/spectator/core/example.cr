require "./context"
require "./item"
require "./result"

module Spectator::Core
  # Information about a test case and functionality for running it.
  class Example < Item
    # Creates a new example.
    #
    # The *description* can be a string, nil, or any other object.
    # When it is a string or nil, it will be stored as-is.
    # Any other types will be converted to a string by calling `#inspect` on it.
    def initialize(description = nil, tags : TagModifiers? = nil, location : LocationRange? = nil, &@block : Example -> Nil)
      super(description, tags, location)
    end

    # Runs the example.
    def run : Result
      @run = true
      @previous_result = Result.capture do
        # Capture exceptions raised in the example block.
        # Defer raising them until after hooks have finished.
        exception = nil.as(Exception?)
        if context = parent
          context.with_hooks(self) do
            @block.call(self)
          rescue ex
            exception = ex
          end
        else
          begin
            @block.call(self)
          rescue ex
            exception = ex
          end
        end
        exception.try { |error| raise error }
      end
    end

    def filter(filter : Filter) : self
      return self if filter.matches?(self)
      group?.try &.remove_child(self)
      self
    end

    # Indicates if the example has been run.
    getter? run : Bool = false

    getter previous_result : Result?

    def group? : ExampleGroup?
      parent.try &.as?(ExampleGroup)
    end

    def group : ExampleGroup
      parent.as(ExampleGroup)
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
      io << " tags: "
      print_tags(io)
      io << " 0x"
      object_id.to_s(io, 16)
      yield io
      io << '>'
    end

    def to_proc(&block : Procsy ->)
      Procsy.new(self, &block)
    end

    def to_proc
      to_proc { run }
    end

    struct Procsy
      @proc : self ->

      def initialize(@example : Example, &@proc : self ->)
      end

      def run
        @proc.call(self)
      end

      def wrap(&block : self ->)
        Procsy.new(@example) do
          block.call(self)
          # TODO: Warn if block did not run example (call #run).
        end
      end

      forward_missing_to @example
      delegate to_s, to: @example

      def inspect(io : IO) : Nil
        @example.inspect(io, &.<< " Procsy")
      end
    end
  end

  module ExampleDSL
  end

  struct ContextDSL
    include ExampleDSL
  end
end

module Spectator
  macro alias_example_to(name, *tags, **tagged_values)
    module ::Spectator::Core::ExampleDSL
      def {{name.id}}(description = nil, *tags,
                      source_file = __FILE__,
                      source_line = __LINE__,
                      source_end_line = __END_LINE__,
                      **tagged_values,
                      &block : Example ->) : Example
        location = LocationRange.new(source_file, source_line, source_end_line)
        example = Example.new(
          description: description.try &.to_s,
          tags: Taggable.create_and_merge_tags(
            tags, tagged_values, {{tags.splat(", ")}} {{tagged_values.double_splat}}),
          location: location,
          &block)
        context.add_child(example)
        example
      end
    end
  end

  alias_example_to :specify
  alias_example_to :it
  alias_example_to :xspecify, skip: "Skipped with xspecify"
  alias_example_to :xit, skip: "Skipped with xit"
end
