require "./mocks/*"

module Spectator
  # Functionality for mocking existing types.
  module Mocks
    def self.run(context : TestContext)
      Registry.prepare(context)
      yield
    ensure
      Registry.reset
    end
  end
end
