require "./dsl"

module Spectator
  module Examples
    include ::Spectator::DSL

    {% ::Spectator::ContextDefinitions::ALL[@type.id] = {
      name: "ROOT",
      parent: nil,
      given: [] of Object
    } %}
    ::Spectator::ContextDefinitions::MAPPING[{{@type.stringify}}] = ::Spectator::Context::ROOT
  end
end
