require "json" # Needed to test masking Object#to_json in doubles.
require "yaml" # Needed to test masking Object#to_yaml in doubles.
require "../src/spectator"
require "../src/spectator/should"
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
