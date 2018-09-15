require "./dsl"
require "./definitions"

module Spectator
  module Examples
    include ::Spectator::DSL::StructureDSL

    {% ::Spectator::Definitions::ALL[@type.id] = {
      name: "ROOT",
      parent: nil,
      given: [] of Object
    } %}
    ::Spectator::Definitions::MAPPING[{{@type.stringify}}] = ::Spectator::ExampleGroup::ROOT
  end
end
