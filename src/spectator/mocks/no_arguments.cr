require "./arguments"

module Spectator::Mocks
  class NoArguments < Arguments
    def args
      Tuple.new
    end

    def opts
      NamedTuple.new
    end

    def ===(other : Arguments) : Bool
      other.args.empty? && other.opts.empty?
    end

    def ===(other) : Bool
      false
    end
  end
end
