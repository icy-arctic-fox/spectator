require "../spec/builder"

module Spectator::DSL
  module Builder
    extend self

    @@builder = Spec::Builder.new

    def start_group(*args)
      @@builder.start_group(*args)
    end

    def end_group(*args)
      @@builder.end_group(*args)
    end
  end
end
