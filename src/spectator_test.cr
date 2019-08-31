require "./spectator/dsl/example_dsl"
require "./spectator/dsl/structure_dsl"

# Root-level class that all tests inherit from and are contained in.
# This class is intentionally outside of the scope of Spectator,
# so that the namespace isn't leaked into tests unexpectedly.
class SpectatorTest
  include ::Spectator::DSL::StructureDSL # Include the DSL for creating groups, example, and more.
  include ::Spectator::DSL::ExampleDSL   # Mix in methods and macros specifically for example DSL.
end
