# Example system to test that doubles as a spy.
# This class tracks calls made to it.
class SpySUT
  {% for item in [
                   {"==", "eq"},
                   {"!=", "ne"},
                   {"<", "lt"},
                   {"<=", "le"},
                   {">", "gt"},
                   {">=", "ge"},
                   {"===", "case_eq"},
                   {"=~", "match"},
                   {"includes?", "includes"},
                 ] %}
  {% operator = item[0].id %}
  {% name = item[1].id %}

  # Number of times the `#{{operator}}` method was called.
  getter {{name}}_call_count = 0

  # Returns true and increments `#{{name}}_call_count`.
  def {{operator}}(other : T) forall T
    @{{name}}_call_count += 1
    true
  end

  {% end %}
end
