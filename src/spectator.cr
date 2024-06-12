require "./spectator/core/**"

# Feature-rich testing framework for Crystal inspired by RSpec.
module Spectator
  # Current version of the Spectator library.
  VERSION = {{ `shards version "#{__DIR__}"`.stringify.chomp }}
end
