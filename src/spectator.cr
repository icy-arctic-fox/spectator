require "./spectator/assertion_failed"
require "./spectator/error"
require "./spectator/example_pending"
require "./spectator/framework_error"

require "./spectator/core/**"
require "./spectator/matchers/**"

# Feature-rich testing framework for Crystal inspired by RSpec.
module Spectator
  # Current version of the Spectator library.
  VERSION = {{ `shards version "#{__DIR__}"`.stringify.chomp }}
end
