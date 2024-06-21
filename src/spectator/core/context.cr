require "./hooks"
require "./item"

module Spectator::Core
  module Context
    include Hooks

    def describe(description, &)
      context(description) { with self yield self }
    end

    abstract def context(description, &)

    def it(description, &block : Example ->) : Example
      Example.new(description, &block).tap do |example|
        example.parent = self
      end
    end
  end
end
