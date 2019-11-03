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

    def ===(other) : Bool
      return false unless @args === other.args
      return false unless @opts.size === other.opts.size

      @opts.keys.all? do |key|
        other.opts.has_key?(key) && @opts[key] === other.opts[key]
      end
    end

    def to_s(io)
      @args.each_with_index do |arg, i|
        arg.inspect(io)
        io << ", " if i < @args.size - 1
      end
      io << ", " unless @args.empty? || @opts.empty?
      @opts.each_with_index do |key, value, i|
        io << key
        io << ": "
        value.inspect(io)
        io << ", " if 1 < @opts.size - 1
      end
    end
  end
end
