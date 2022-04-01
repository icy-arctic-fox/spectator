require "./stub"
require "./stubbable"

module Spectator
  struct Allow(T)
    def initialize(@target : T)
      {% raise "Target of `allow` must be stubbable (a mock or double)." unless T < Stubbable %}
    end

    def to(stub : Stub) : Nil
      @target._spectator_define_stub(stub)
    end
  end
end
