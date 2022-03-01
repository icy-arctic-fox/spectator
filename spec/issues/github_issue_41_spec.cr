require "../spec_helper"

Spectator.describe "GitHub Issue #41" do
  sample [1, 2, 3] do |i|
    it "is itself" do
      expect(i).to eq i
    end
  end

  def self.an_array
    [1, 2, 3]
  end

  sample an_array do |i|
    it "is itself" do
      expect(i).to eq(i)
    end
  end

  # NOTE: NamedTuple does not work, must be Enumerable(T) for `sample`.
  def self.a_hash
    {:a => "a", :b => "b", :c => "c"}
  end

  sample a_hash do |k, v|
    it "works on hashes" do
      expect(v).to eq(k.to_s)
    end
  end
end
