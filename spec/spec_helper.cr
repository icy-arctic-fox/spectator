require "../src/spectator"

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
