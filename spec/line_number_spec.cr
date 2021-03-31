require "./spec_helper"

Spectator.describe Spectator do
  let(current_example) { ::Spectator::Example.current }
  subject(source) { current_example.source }

  context "line numbers" do
    it "contains starting line of spec" do
      expect(source.line).to eq(__LINE__ - 1)
    end

    it "contains ending line of spec" do
      expect(source.end_line).to eq(__LINE__ + 1)
    end

    it "handles multiple lines and examples" do
      # Offset is important.
      expect(source.line).to eq(__LINE__ - 2)
      # This line fails, refer to https://github.com/crystal-lang/crystal/issues/10562
      # expect(source.end_line).to eq(__LINE__ + 2)
      # Offset is still important.
    end
  end

  context "file names" do
    subject { source.file }

    it "match source code" do
      is_expected.to eq(__FILE__)
    end
  end
end
