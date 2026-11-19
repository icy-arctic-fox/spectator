require "../../spec_helper"

Spectator.shared_examples :test_examples,
  prop_a : Int32 = 0,
  prop_b = "test",
  prop_c : Symbol,
  prop_d : Nil,
  prop_e : String? do |ctx|
  it "works" do
    expect(ctx.prop_a).to eq(42)
    expect(ctx.prop_b).to eq("test")
    expect(ctx.prop_c).to eq(:xyz)
  end
end

Spectator.shared_examples :unrelated,
  prop_f : Int32,
  prop_g : String do
end

Spectator.describe Spectator::Core::SharedExampleGroup do
  # it_behaves_like :test_examples, prop_a: 42, prop_c: :xyz
end
