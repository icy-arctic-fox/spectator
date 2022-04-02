require "./stub"
require "./stubbable"

module Spectator
  # Targets a stubbable object.
  #
  # This type is effectively part of the mock DSL.
  # It is primarily used in the mock DSL to provide this syntax:
  # ```
  # allow(dbl).to
  # ```
  struct Allow(T)
    # Creates the stub target.
    #
    # The *target* must be a kind of `Stubbable`.
    def initialize(@target : T)
      {% raise "Target of `allow` must be stubbable (a mock or double)." unless T < Stubbable %}
    end

    # Applies a stub to the targeted stubbable object.
    def to(stub : Stub) : Nil
      @target._spectator_define_stub(stub)
    end
  end
end
