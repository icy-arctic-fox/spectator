require "../spec_helper"

Spectator.describe "Spec metadata" do
  let(interpolation) { "string interpolation" }

  it "supports #{interpolation}" do |example|
    expect(example.name).to eq("supports string interpolation")
  end

  def self.various_strings
    %w[foo bar baz]
  end

  sample various_strings do |string|
    it "works with #{string}" do |example|
      expect(example.name).to eq("works with #{string}")
    end
  end
end
