module Spectator::Matchers
  struct LabeledValue
    getter label : Symbol

    getter value : String

    def initialize(@label, @value)
    end
  end
end
