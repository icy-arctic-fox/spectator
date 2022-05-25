require "../spec_helper"

Spectator.describe "Spec metadata", :smoke do
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

  def self.a_hash
    {"foo" => 42, "bar" => 123, "baz" => 7}
  end

  sample a_hash do |key, value|
    it "works with #{key} = #{value}" do |example|
      expect(example.name).to eq("works with #{key} = #{value}")
    end
  end
end
