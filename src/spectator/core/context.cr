require "./hooks"
require "./example"

module Spectator::Core
  module Context
    include Hooks

    abstract def context(description, &)

    def describe(description, &)
      context(description) { with self yield self }
    end

    abstract def specify(description, &block : Example ->) : Example

    def it(description, &block : Example ->) : Example
      specify(description, &block)
    end
  end
end
