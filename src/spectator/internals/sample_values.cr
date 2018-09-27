require "./value_wrapper"

module Spectator::Internals
  struct SampleValues
    private record Entry, name : String, wrapper : ValueWrapper

    def self.empty
      new({} of Symbol => Entry)
    end

    protected def initialize(@values = {} of Symbol => Entry)
    end

    def add(id : Symbol, name : String, value : T) : SampleValues forall T
      wrapper = TypedValueWrapper(T).new(value)
      SampleValues.new(@values.merge({
        id => Entry.new(name, wrapper)
        }))
    end

    def get_wrapper(id : Symbol)
      @values[id].wrapper
    end
  end
end
