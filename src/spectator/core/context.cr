require "./hooks"
require "./example"

module Spectator::Core
  module Context(T)
    include Hooks

    abstract def context(description, &)

    def describe(description, &)
      context(description) { with self yield self }
    end

    abstract def specify(description, &block : T ->) : T

    def it(description, &block : T ->) : T
      specify(description, &block)
    end
  end
end
