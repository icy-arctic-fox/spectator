require "./example_group"

module Spectator
  class GivenExampleGroup(T) < ExampleGroup
    def initialize(what, @collection : Array(T), @symbol : Symbol, parent = nil)
      super(what, parent)
    end

    def example_count
      super * @collection.size
    end

    def all_examples(locals = {} of Symbol => ValueWrapper)
      Array(Example).new(example_count).tap do |array|
        @collection.each do |local|
          wrapper = TypedValueWrapper(T).new(local)
          iter_locals = locals.merge({@symbol => wrapper})
          array.concat(super(iter_locals))
        end
      end
    end
  end
end
