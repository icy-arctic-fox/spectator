require "./spectator_context"
require "./spectator/dsl"

class SpectatorTestContext < SpectatorContext
  include ::Spectator::DSL::Examples
  include ::Spectator::DSL::Groups
  include ::Spectator::DSL::Hooks

  # Initial implicit subject for tests.
  # This method should be overridden by example groups when an object is described.
  private def _spectator_implicit_subject
    nil
  end

  # Initial subject for tests.
  # Returns the implicit subject.
  # This method should be overridden when an explicit subject is defined by the DSL.
  # TODO: Subject needs to be cached.
  private def subject
    _spectator_implicit_subject
  end

  # def initialize(@spectator_test_values : ::Spectator::TestValues)
  # end
end
