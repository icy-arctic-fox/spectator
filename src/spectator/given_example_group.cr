require "./example_group"

module Spectator
  class GivenExampleGroup(T) < ExampleGroup
    def initialize(what, @collection : Array(T), parent = nil)
      super(what, parent)
    end

    protected def add_examples(array : Array(Example))
      @collection.each do |item|
        super(array)
      end
    end
  end
end
