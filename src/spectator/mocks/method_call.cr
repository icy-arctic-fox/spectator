module Spectator::Mocks
  abstract class MethodCall
    getter name : Symbol

    def initialize(@name : Symbol)
    end

    def to_s(io)
      io << '#'
      io << @name
    end
  end
end
