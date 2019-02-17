require "./spec_helper"

describe Spectator::Source do
  describe "#file" do
    it "is the expected value" do
      file = __FILE__
      source = Spectator::Source.new(file, __LINE__)
      source.file.should eq(file)
    end
  end

  describe "#line" do
    it "is the expected value" do
      line = __LINE__
      source = Spectator::Source.new(__FILE__, line)
      source.line.should eq(line)
    end
  end

  describe "#to_s" do
    it "is formatted correctly" do
      file = __FILE__
      line = __LINE__
      source = Spectator::Source.new(file, line)
      source.to_s.should eq("#{file}:#{line}")
    end
  end
end
