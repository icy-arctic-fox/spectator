module Spectator::Core
  def self.uninitialized_value_from_proc(proc : -> T) : T forall T
    # The `uninitialized` keyword can't be used without assigning it to a variable.
    # The compiler produces: `Error: undefined method 'uninitialized' for top-level`.
    # This is a workaround.
    value = uninitialized T
    value
  end

  module Helpers
    macro let(expr)
      %block = -> do
        {{expr.value}}
      end

      {{expr.target}} = %block.call

      before_each! do
        {{expr.target}} = %block.call
      end
    end

    macro let!(expr)
      %block = -> do
        {{expr.value}}
      end

      {{expr.target}} = ::Spectator::Core.uninitialized_value_from_proc(%block)

      before_each! do
        {{expr.target}} = %block.call
      end
    end
  end
end
