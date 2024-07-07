module Spectator::Core
  module Helpers
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
