require "../spec_helper"

Spectator.describe "Spec metadata" do
  let(interpolation) { "string interpolation" }

  it "supports #{interpolation}" do |example|
    expect(example.name).to eq("supports string interpolation")
  end
end
