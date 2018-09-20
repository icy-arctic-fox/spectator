require "./example_group"

module Spectator
  class GivenExampleGroup(T) < ExampleGroup
    @mapping = {} of Example => T

    def initialize(what, @collection : Array(T), parent = nil)
      super(what, parent)
    end

    protected def add_examples(array : Array(Example))
      @collection.each do |value|
        examples = super.all_examples
        examples.each do |example|
          @mapping[example] = value
        end
        array.concat(examples)
      end
    end

    def value_for(example : Example) : T
      @mapping[example]
    end
  end
end
