module Spectator
  private abstract class RunOrder
    abstract def sort(a : Example, b : Example) : Int32
  end
end
