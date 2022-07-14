require "../spec_helper"

# https://gitlab.com/arctic-fox/spectator/-/wikis/Anonymous-Doubles
Spectator.describe "Anonymous Doubles Docs" do
  it "does something" do
    dbl = double(foo: 42)
    expect(dbl.foo).to eq(42)
  end

  it "does something" do
    dbl = double(foo: 42)
    allow(dbl).to receive(:foo).and_return(123)
    expect(dbl.foo).to eq(123)
  end
end
