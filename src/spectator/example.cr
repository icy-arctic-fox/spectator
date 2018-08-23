module Spectator
  class Example
    def initialize(@description : String, @block : ->)
    end

    def run
      @block.call
    rescue ex : ExpectationFailedError
      puts ex
    end
  end
end
