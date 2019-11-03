module Spectator::Mocks
  abstract class MethodCall
    getter name : Symbol

    def initialize(@name : Symbol)
    end
  end
end
