require "./value_proxy"

module Spectator
  class TypedValueProxy(T) < ValueProxy
    getter value : T

    def initialize(@value : T)
    end
  end
end
