module Spectator
  class Example
    def initialize(@description : String, @block : ->)
    end

    def run
      @block.call
    end
  end
end
