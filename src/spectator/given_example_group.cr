require "./example_group"

module Spectator
  class GivenExampleGroup(T) < ExampleGroup
    @mapping = {} of Example => T

    def initialize(what, @collection : Array(T), parent = nil)
      super(what, parent)
    end

    def example_count
      super * @collection.size
    end

    def all_examples
      Array(Example).new(example_count).tap do |array|
        examples = super
        @collection.each do |value|
          examples.each do |example|
            @mapping[example] = value
          end
          array.concat(examples)
        end
      end
    end

    def value_for(example : Example) : T
      @mapping[example]
    end
  end
end
