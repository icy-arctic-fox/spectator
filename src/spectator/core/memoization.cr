module Spectator::Core
  def self.null_value(type : T.class) : T forall T
    value = uninitialized T
  end

  module Memoization
    macro let(expr)
      {{expr}}

      %block = -> do
        {{expr.value}}
      end

      before_each! do
        {{expr.target}} = %block.call
      end
    end
  end
end
