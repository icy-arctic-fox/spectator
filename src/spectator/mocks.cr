require "./mocks/*"
require "./system_exit"

module Spectator
  # Functionality for mocking existing types.
  module Mocks
  end
end

# Add default stub to `exit` method.
# This captures *most* (technically not all) attempts to exit the process.
# This stub only takes effect in example code.
# It intercepts `exit` calls and raises `Spectator::SystemExit` to prevent killing the test.
# class ::Process
#   include ::Spectator::Mocks::Stubs

#   stub self.exit(code) { raise ::Spectator::SystemExit.new }
# end
