require "./example"
require "./location"

module Spectator::Core
  abstract struct Filter
    abstract def matches?(example : Example)
  end

  struct ExampleFilter < Filter
    def initialize(@substring : String)
    end

    def matches?(example : Example)
      example.full_description.try &.includes?(@substring)
    end
  end

  struct LineFilter < Filter
    def initialize(@line : Int32)
    end

    def matches?(example : Example)
      example.location.try &.includes?(@line)
    end
  end

  struct LocationFilter < Filter
    def initialize(@location : Location)
    end

    def matches?(example : Example)
      example.location.try &.includes?(@location)
    end
  end

  struct CompoundFilter < Filter
    def initialize(@filters : Array(Filter))
    end

    def matches?(example : Example)
      @filters.any? &.matches?(example)
    end

    def add_filter(filter : Filter)
      @filters << filter
    end
  end
end
