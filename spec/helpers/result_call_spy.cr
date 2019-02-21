# Spy class for testing `Spectator::Result#call`.
class ResultCallSpy
  {% for name in %i[success failure error pending] %}
  getter? {{name.id}} = false

  def {{name.id}}
    @{{name.id}} = true
    {{name}}
  end

  def {{name.id}}(arg)
    @{{name.id}} = true
    arg
  end
  {% end %}
end
