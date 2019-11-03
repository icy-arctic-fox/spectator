require "./arguments"

module Spectator::Mocks
  class GenericArguments(T, NT) < Arguments
    protected getter args
    protected getter opts

    def initialize(@args : T, @opts : NT)
    end

    def self.create(*args, **opts)
      GenericArguments.new(args, opts)
    end

    def pass_to(dispatcher)
      dispatcher.call(*@args, **@opts)
    end

    def ===(other : Arguments(U, NU)) : Bool forall U, NU
      return false unless @args === other.args
      return false unless @opts.size === other.opts.size

      @opts.keys.all? do |key|
        other.opts.has_key?(key) && @opts[key] === other.opts[key]
      end
    end
  end
end
