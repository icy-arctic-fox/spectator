module Spectator
  # Untyped arguments to a method call (message).
  abstract class AbstractArguments
    # Use the string representation to avoid over complicating debug output.
    def inspect(io : IO) : Nil
      to_s(io)
    end

    # Utility method for comparing two tuples considering special types.
    private def compare_tuples(a : Tuple | Array, b : Tuple | Array)
      return false if a.size != b.size

      a.zip(b) do |a_value, b_value|
        return false unless compare_values(a_value, b_value)
      end
      true
    end

    # Utility method for comparing two tuples considering special types.
    # Supports nilable tuples (ideal for splats).
    private def compare_tuples(a : Tuple? | Array?, b : Tuple? | Array?)
      return false if a.nil? ^ b.nil?

      compare_tuples(a.not_nil!, b.not_nil!)
    end

    # Utility method for comparing two named tuples ignoring order.
    private def compare_named_tuples(a : NamedTuple | Hash, b : NamedTuple | Hash)
      a.each do |k, v1|
        v2 = b.fetch(k) { return false }
        return false unless compare_values(v1, v2)
      end
      true
    end

    # Utility method for comparing two arguments considering special types.
    # Some types used for case-equality don't work well with unexpected right-hand types.
    # This can happen when the right side is a massive union of types.
    private def compare_values(a, b)
      case a
      when Proc
        # Using procs as argument matchers isn't supported currently.
        # Compare directly instead.
        a == b
      when Range
        # Ranges can only be matched against if their right side is comparable.
        # Ensure the right side is comparable, otherwise compare directly.
        return a === b if b.is_a?(Comparable(typeof(b)))
        a == b
      when Tuple, Array
        return compare_tuples(a, b) if b.is_a?(Tuple) || b.is_a?(Array)
        a === b
      when NamedTuple, Hash
        return compare_named_tuples(a, b) if b.is_a?(NamedTuple) || b.is_a?(Hash)
        a === b
      else
        a === b
      end
    end
  end
end
