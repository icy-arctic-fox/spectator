require "../spec_helper"

Spectator.describe "Interpolated Label", :smoke do
  let(foo) { "example" }
  let(bar) { "context" }

  it "interpolates #{foo} labels" do |example|
    expect(example.name).to eq("interpolates example labels")
  end

  context "within a #{bar}" do
    let(foo) { "multiple" }

    it "interpolates context labels" do |example|
      expect(example.group.name).to eq("within a context")
    end

    it "interpolates #{foo} levels" do |example|
      expect(example.name).to eq("interpolates multiple levels")
    end
  end
end
