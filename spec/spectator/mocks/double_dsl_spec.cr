require "../../spec_helper"

Spectator.describe "Double DSL" do
  double(:foo, foo: 42, bar: "baz") do
  end

  let(dbl) { double(:foo) }

  specify do
    expect(dbl.foo).to eq(42)
    expect(dbl.bar).to eq("baz")
    expect(dbl.foo).to compile_as(Int32)
    expect(dbl.bar).to compile_as(String)
  end
end
