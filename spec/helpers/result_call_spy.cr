# Spy class for testing `Spectator::Result#call`.
class ResultCallSpy
  {% for name in %i[success failure error pending] %}
  getter! {{name.id}} : ::Spectator::Result

  def {{name.id}}(arg)
    @{{name.id}} = arg
  end
  {% end %}
end
