require "./context"
require "./dsl"

# Class used as the base for all specs using the DSL.
# It adds methods and macros necessary to use the DSL from the spec.
# This type is intentionally outside the `Spectator` module.
# The reason for this is to prevent name collision when using the DSL to define a spec.
class SpectatorTestContext < SpectatorContext
  include ::Spectator::DSL::Examples
  include ::Spectator::DSL::Expectations
  include ::Spectator::DSL::Groups
  include ::Spectator::DSL::Hooks
  include ::Spectator::DSL::Matchers
  include ::Spectator::DSL::Values

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
end
