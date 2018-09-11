require "./example"

module Spectator
  class Context
    getter examples = [] of Example
    getter contexts = [] of Context

    def all_examples
      add_examples
    end

    protected def add_examples(array = [] of Example)
      array.concat(@examples)
      contexts.each do |context|
        context.add_examples(array)
      end
      array
    end
  end
end
