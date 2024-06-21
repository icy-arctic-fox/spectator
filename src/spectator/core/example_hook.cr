require "./example"
require "./location_range"

module Spectator::Core
  class ExampleHook(T)
    getter! location : LocationRange

    getter! exception : Exception

    def initialize(@location = nil, &@block : T ->)
    end

    def initialize(@block : T ->)
    end

    def call(example : T)
      # Re-raise previous error if there was one.
      @exception.try { |ex| raise ex }

      begin
        @block.call(example)
      rescue ex
        @exception = ex
        raise ex
      end
    end
  end
end
