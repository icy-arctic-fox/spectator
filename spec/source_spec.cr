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

  describe "#path" do
    context "with a relative file" do
      it "is shortened" do
        file = "test.cr"
        absolute = File.join(Dir.current, file)
        source = Spectator::Source.new(absolute, __LINE__)
        source.path.should eq(file)
      end
    end

    context "with a different directory" do
      it "is the absolute path" do
        file = "/foo/bar/baz.cr"
        source = Spectator::Source.new(file, __LINE__)
        source.path.should eq(file)
      end
    end
  end

  describe "#to_s" do
    it "contains #path" do
      file = __FILE__
      source = Spectator::Source.new(file, __LINE__)
      source.to_s.should contain(source.path)
    end

    it "contains #line" do
      line = __LINE__
      source = Spectator::Source.new(__FILE__, line)
      source.to_s.should contain(line.to_s)
    end

    it "is formatted correctly" do
      source = Spectator::Source.new(__FILE__, __LINE__)
      source.to_s.should match(/^(.+?)\:(\d+)$/)
    end
  end

  describe "#parse" do
    it "gets the absolute path" do
      file = "foo.cr"
      path = File.expand_path(file)
      source = Spectator::Source.parse("#{file}:42")
      source.file.should eq(path)
    end

    it "gets the relative path" do
      source = Spectator::Source.parse("foo.cr:42")
      source.path.should eq("foo.cr")
    end

    it "gets the line number" do
      source = Spectator::Source.parse("foo.cr:42")
      source.line.should eq(42)
    end
  end
end
