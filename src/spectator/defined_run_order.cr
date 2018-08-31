require "./run_order"

module Spectator
  private class DefinedRunOrder < RunOrder
    def sort(a : Example, b : Example) : Int32
      -1
    end
  end
end
