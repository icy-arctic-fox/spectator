module Spectator::Core
  def self.null_value(type : T.class) : T forall T
    value = uninitialized T
  end

  module Memoization
    macro let(name, &block)
      %block = -> do
        {{yield}}
      end

      {{name.id}} = ::Spectator::Core.null_value(typeof(%block.call))

      before_each do # TODO: Ensure hook is called before all others.
        {{name.id}} = %block.call
      end

      {% debug %}
    end
  end
end
