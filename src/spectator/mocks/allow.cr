require "../harness"
require "./stub"
require "./stubbable"
require "./stubbed_type"

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
    # The *target* must be a kind of `Stubbable` or `StubbedType`.
    def initialize(@target : T)
      {% raise "Target of `allow` must be stubbable (a mock or double)." unless T < Stubbable || T < StubbedType %}
    end

    # Applies a stub to the targeted stubbable object.
    def to(stub : Stub) : Nil
      @target._spectator_define_stub(stub)
      Harness.current?.try &.cleanup { @target._spectator_remove_stub(stub) }
    end
  end
end
