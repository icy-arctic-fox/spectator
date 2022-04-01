require "../../../spec_helper"

Spectator.describe "Stubs DSL" do
  double(:foobar, foo: 42, bar: "baz")
  let(dbl) { double(:foobar) }

  specify do
    allow(dbl).to receive(:foo).and_return(123)
    expect(dbl.foo).to eq(123)
  end
end
