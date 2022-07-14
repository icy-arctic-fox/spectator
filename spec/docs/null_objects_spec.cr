require "../spec_helper"

# https://gitlab.com/arctic-fox/spectator/-/wikis/Null-Objects
Spectator.describe "Null Objects Docs" do
  double :my_double

  it "returns itself for undefined methods" do
    dbl = double(:my_double).as_null_object
    expect(dbl.some_undefined_method).to be(dbl)
  end

  it "can be used to chain methods" do
    dbl = double(:my_double).as_null_object
    expect(dbl.foo.bar.baz).to be(dbl)
  end
end
