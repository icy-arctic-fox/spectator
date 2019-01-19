# Example system to test that doubles as a spy.
# This class tracks calls made to it.
class SpySUT
  # Number of times the `#==` method was called.
  getter eq_call_count = 0

  # Number of times the `#===` method was called.
  getter case_eq_call_count = 0

  # Returns true and increments `#eq_call_count`.
  def ==(other : T) forall T
    @eq_call_count += 1
    true
  end

  # Returns true and increments `#case_eq_call_count`.
  def ===(other : T) forall T
    @case_eq_call_count += 1
    true
  end
end
