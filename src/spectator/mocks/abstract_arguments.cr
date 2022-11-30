module Spectator
  # Untyped arguments to a method call (message).
  abstract class AbstractArguments
    # Use the string representation to avoid over complicating debug output.
    def inspect(io : IO) : Nil
      to_s(io)
    end

    # Utility method for comparing two named tuples ignoring order.
    private def compare_named_tuples(a : NamedTuple, b : NamedTuple)
      a.each do |k, v1|
        v2 = b.fetch(k) { return false }
        return false unless v1 === v2
      end
      true
    end
  end
end
