require "../reporters"

module Spectator::Formatting
  abstract class Formatter < Reporters::Reporter
    def initialize(@output : IO)
    end
  end
end
