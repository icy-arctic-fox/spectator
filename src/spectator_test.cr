require "./spectator/dsl"

# Root-level class that all tests inherit from and are contained in.
# This class is intentionally outside of the scope of Spectator,
# so that the namespace isn't leaked into tests unexpectedly.
class SpectatorTest
  include ::Spectator::DSL
end
