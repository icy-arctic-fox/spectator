require "./spec_helper"

Spectator.describe Spectator do
  let(current_example) { ::Spectator::Harness.current.example }
  subject(source) { current_example.source }

  context "line numbers" do
    subject { source.line }

    it "match source code" do
      is_expected.to eq(__LINE__ - 1)
    end

    it "handles multiple lines and examples" do
      # Offset is important.
      is_expected.to eq(__LINE__ - 2)
    end
  end

  context "file names" do
    subject { source.file }

    it "match source code" do
      is_expected.to eq(__FILE__)
    end
  end
end
