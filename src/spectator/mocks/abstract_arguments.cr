module Spectator
  # Untyped arguments to a method call (message).
  abstract class AbstractArguments
    # Use the string representation to avoid over complicating debug output.
    def inspect(io : IO) : Nil
      to_s(io)
    end

    # Utility method for comparing two tuples considering special types.
    private def compare_tuples(a : Tuple, b : Tuple)
      return false if a.size != b.size

      a.zip(b) do |a_value, b_value|
        if a_value.is_a?(Proc)
          # Using procs as argument matchers isn't supported currently.
          # Compare directly instead.
          return false unless a_value == b_value
        else
          return false unless a_value === b_value
        end
      end
      true
    end

    # Utility method for comparing two tuples considering special types.
    # Supports nilable tuples (ideal for splats).
    private def compare_tuples(a : Tuple?, b : Tuple?)
      return false if a.nil? ^ b.nil?

      compare_tuples(a.not_nil!, b.not_nil!)
    end

    # Utility method for comparing two named tuples ignoring order.
    private def compare_named_tuples(a : NamedTuple, b : NamedTuple)
      a.each do |k, v1|
        v2 = b.fetch(k) { return false }
        if v1.is_a?(Proc)
          # Using procs as argument matchers isn't supported currently.
          # Compare directly instead.
          return false unless v1 == v2
        else
          return false unless v1 === v2
        end
      end
      true
    end
  end
end
