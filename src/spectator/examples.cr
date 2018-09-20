require "./dsl"
require "./definitions"

module Spectator
  module Examples
    include ::Spectator::DSL::StructureDSL

    {% ::Spectator::Definitions::ALL[@type.id] = {
      name: "ROOT",
      parent: nil,
      given: [] of Object,
      children: [] of Object
    } %}
    ::Spectator::Definitions::GROUPS[{{@type.stringify}}] = ::Spectator::ExampleGroup::ROOT
  end
end
