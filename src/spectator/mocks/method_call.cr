module Spectator::Mocks
  class MethodCall
    getter name : Symbol
    getter args : Arguments

    def initialize(@name : Symbol, @args : Arguments)
    end

    def to_s(io)
      io << '#'
      io << @name
    end
  end
end
