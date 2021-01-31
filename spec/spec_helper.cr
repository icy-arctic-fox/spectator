require "../src/spectator"
require "../src/spectator/should"
require "./helpers/**"

macro it_fails(description = nil, &block)
  it {{description}} do
    expect do
      {{block.body}}
    end.to raise_error(Spectator::ExpectationFailed)
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

# Defines an example ("it" block) that is lazily compiled.
# The "it" block must be omitted, as the block provided to this macro will be wrapped in one.
# When the expectation is referenced with *id*, it will be compiled and the result retrieved.
# The value returned by *id* will be a `Spectator::SpecHelpers::Expectation`.
# This allows an expectation to be inspected.
# Only the last expectation performed will be returned.
# An error is raised if no expectations ran.
macro given_expectation(id, &block)
  let({{id}}) do
    result = ::Spectator::SpecHelpers::Example.new(
      {{__FILE__}},
      {{id.id.stringify}},
      {{"it do\n" + block.body.stringify + "\nend"}}
    ).result
    result.expectations.last || raise("No expectations found from {{id.id}}")
  end
end
