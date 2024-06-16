module Spectator::Core
  module Methods
    def context(description : String, &)
      example_group = ExampleGroup.new(description)
      Spectator.current_example_group.push(example_group) do
        with self yield
      end
    end

    def describe(description : String, &)
      context(description) { yield }
    end

    def it(description : String)
    end

    def it(description : String, & : Example ->)
    end

    def pending(description : String)
    end

    def pending(description : String, & : Example ->)
    end
  end
end
