require "../src/spectator"
require "./helpers/**"

macro it_fails(description = nil, &block)
  it {{description}} do
    expect do
      {{block.body}}
    end.to raise_error(Spectator::ExampleFailed)
  end
end

macro specify_fails(description = nil, &block)
  it_fails {{description}} {{block}}
end

# Defines an example ("it" block) that is lazily compiled.
# When the example is referenced with *id*, it will be compiled and the results retrieved.
# The value returned by *id* will be a `Spectator::SpecHelpers::Result`.
# This allows the test result to be inspected.
macro given_example(id, &block)
  let({{id}}) do
    ::Spectator::SpecHelpers::Example.new(
      {{__FILE__}},
      {{id.id.stringify}},
      {{block.body.stringify}}
    ).result
  end
end
