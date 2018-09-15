require "./dsl"
require "./group_definitions"

module Spectator
  module Examples
    include ::Spectator::DSL

    {% ::Spectator::GroupDefinitions::ALL[@type.id] = {
      name: "ROOT",
      parent: nil,
      given: [] of Object
    } %}
    ::Spectator::GroupDefinitions::MAPPING[{{@type.stringify}}] = ::Spectator::ExampleGroup::ROOT
  end
end
