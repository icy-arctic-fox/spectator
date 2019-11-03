require "./method_call"

module Spectator::Mocks
  class GenericMethodCall(T, NT) < MethodCall
    getter args : T

    getter options : NT

    def initialize(name : Symbol, @args : T, @options : NT)
      super(name)
    end

    def self.create(name : Symbol, *args, **options)
      GenericMethodCall.new(name, args, options)
    end

    def to_s(io)
      io << name
      return if @args.empty? && @options.empty?

      io << '('
      io << @args
      io << ", " if @args.any?
      io << @options
      io << ')'
    end
  end
end
