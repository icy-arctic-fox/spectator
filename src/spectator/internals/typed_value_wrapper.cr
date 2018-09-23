require "./value_wrapper"

module Spectator
  module Internals
    class TypedValueWrapper(T) < ValueWrapper
      getter value : T

      def initialize(@value : T)
      end
    end
  end
end
