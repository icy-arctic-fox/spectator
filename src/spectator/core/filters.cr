require "./example"
require "./location"

module Spectator::Core
  abstract class Filter
    abstract def matches?(example : Example)
  end

  class ExampleFilter < Filter
    def initialize(@substring : String)
    end

    def matches?(example : Example)
      example.full_description.try &.includes?(@substring)
    end
  end

  class LineFilter < Filter
    def initialize(@line : Int32)
    end

    def matches?(example : Example)
      example.location.try &.includes?(@line)
    end
  end

  class LocationFilter < Filter
    def initialize(@location : Location)
    end

    def matches?(example : Example)
      example.location.try &.includes?(@location)
    end
  end

  class TagFilter < Filter
    @tags = [] of {String, String?}

    def matches?(example : Example)
      example_tags = example.all_tags
      @tags.any? do |(tag, value)|
        value ? example_tags[tag]? == value : example_tags.has_key?(tag)
      end
    end

    def add_tag(tag : String, value : String? = nil)
      @tags << {tag, value}
    end
  end

  class NegatedFilter < Filter
    def initialize(@filter : Filter)
    end

    def matches?(example : Example)
      !@filter.matches?(example)
    end
  end

  class CompoundFilter < Filter
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
