require "../spec_helper"

Spectator.describe String do
  let(normal_string) { "foobar" }
  let(empty_string) { "" }

  describe "#empty?" do
    subject { string.empty? }

    context "when empty" do
      let(string) { empty_string }

      it "is true" do
        is_expected.to be_true
      end
    end

    context "when not empty" do
      let(string) { normal_string }

      it "is false" do
        is_expected.to be_false
      end
    end
  end
end

Spectator.describe Bytes do
  it "stores an array of bytes" do
    bytes = Bytes.new(32)
    bytes[0] = 42
    expect(bytes[0]).to eq(42)
  end
end
