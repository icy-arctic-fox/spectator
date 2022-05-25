require "../spec_helper"

Spectator.describe String do
  # This is a helper method.
  def random_string(length)
    chars = ('a'..'z').to_a
    String.build(length) do |builder|
      length.times { builder << chars.sample }
    end
  end

  describe "#size" do
    subject { random_string(10).size }

    it "is the length of the string" do
      is_expected.to eq(10)
    end
  end
end

Spectator.describe String do
  # length is now pulled from value defined by `let`.
  def random_string
    chars = ('a'..'z').to_a
    String.build(length) do |builder|
      length.times { builder << chars.sample }
    end
  end

  describe "#size" do
    let(length) { 10 } # random_string uses this.
    subject { random_string.size }

    it "is the length of the string" do
      is_expected.to eq(length)
    end
  end
end

module StringHelpers
  def random_string
    chars = ('a'..'z').to_a
    String.build(length) do |builder|
      length.times { builder << chars.sample }
    end
  end
end

Spectator.describe String do
  include StringHelpers

  describe "#size" do
    let(length) { 10 }
    subject { random_string.size }

    it "is the length of the string" do
      is_expected.to eq(length)
    end
  end
end
