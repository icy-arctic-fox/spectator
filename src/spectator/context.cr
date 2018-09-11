require "./example"

module Spectator
  class Context
    getter parent : Context?
    getter examples = [] of Example
    getter contexts = [] of Context
    getter before_all_hooks = [] of ->
    getter before_each_hooks = [] of ->
    getter after_all_hooks = [] of ->
    getter after_each_hooks = [] of ->
    getter around_each_hooks = [] of Example ->

    def initialize(@parent = nil)
      if (parent = @parent)
        parent.contexts << self
      end
    end

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
