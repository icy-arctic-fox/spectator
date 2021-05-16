module Spectator::Formatting::Components
  struct Comment(T)
    private COLOR = :cyan

    def initialize(@content : T)
    end

    def self.colorize(content)
      new(content).colorize(COLOR)
    end

    def to_s(io)
      io << '#'
      io << ' '
      io << @content
    end
  end
end
