require "./arguments"

module Spectator
  # Mixin intended for `Stub` to return new, modified stubs.
  module StubModifiers
    # Returns a new stub of the same type with constrained arguments.
    abstract def with_constraint(constraint : AbstractArguments?)

    # :ditto:
    @[AlwaysInline]
    def with(constraint : AbstractArguments?)
      with_constraint(constraint)
    end

    # :ditto:
    def with(*args, **kwargs)
      constraint = Arguments.new(args, kwargs).as(AbstractArguments)
      self.with_constraint(constraint)
    end
  end
end
