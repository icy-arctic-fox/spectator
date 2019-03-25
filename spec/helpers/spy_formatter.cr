# Formatter that doubles as a spy.
# This class tracks calls made to it.
class SpyFormatter < Spectator::Formatting::Formatter
  {% for item in [
                   {"start_suite", "Spectator::TestSuite"},
                   {"start_example", "Spectator::Example"},
                   {"end_example", "Spectator::Result"},
                 ] %}
  {% method_name = item[0].id %}
  {% argument_type = item[1].id %}

  # Stores all invocations made to `#{{method_name}}`.
  # Each element is an invocation and the value is the argument passed to the method.
  getter {{method_name}}_calls = [] of {{argument_type}}

  # Number of times the `#{{method_name}}` method was called.
  def {{method_name}}_call_count
    @{{method_name}}_calls.size
  end

  # Increments `#{{method_name}}_call_count` and stores the argument.
  def {{method_name}}(arg : {{argument_type}})
    @all_calls << {{method_name.symbolize}}
    @{{method_name}}_calls << arg
  end

  {% end %}

  # Stores all invocatiosn made to `#end_suite`.
  # Each element is an invocation and the value is the arguments passed to the method.
  getter end_suite_calls = [] of NamedTuple(report: Spectator::Report, profile: Spectator::Profile?)

  # Number of times the `#end_suite` method was called.
  def end_suite_call_count
    @end_suite_calls.size
  end

  # Increments `#end_suite_call_count` and stores the arguments.
  def end_suite(report, profile)
    @all_calls << :end_suite
    @end_suite_calls << {report: report, profile: profile}
  end

  # Stores the methods that were called and in which order.
  # The symbols will be the method name (i.e. `:start_suite`).
  getter all_calls = [] of Symbol
end
