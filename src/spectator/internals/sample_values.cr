require "./value_wrapper"

module Spectator::Internals
  struct SampleValues
    def self.empty
      new({} of Symbol => Entry)
    end

    protected def initialize(@values = {} of Symbol => Entry)
    end

    def add(id : Symbol, name : String, value : T) : SampleValues forall T
      wrapper = TypedValueWrapper(T).new(value)
      SampleValues.new(@values.merge({
        id => Entry.new(name, wrapper),
      }))
    end

    def get_wrapper(id : Symbol)
      @values[id].wrapper
    end

    def get_value(id : Symbol, value_type : T.class) : T forall T
      get_wrapper(id).as(TypedValueWrapper(T)).value
    end

    private struct Entry
      getter name : String
      getter wrapper : ValueWrapper

      def initialize(@name, @wrapper)
      end
    end
  end
end
