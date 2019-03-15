require "../spec_helper"

describe Spectator::Formatting::Color do
  describe "#success" do
    it "includes the input text" do
      text = "foobar"
      output = Spectator::Formatting::Color.success(text)
      output.to_s.should contain(text)
    end

    it "prefixes with green markers" do
      output = Spectator::Formatting::Color.success("foobar")
      output.to_s.should start_with("\e[32m")
    end

    it "appends color reset markers" do
      output = Spectator::Formatting::Color.success("foobar")
      output.to_s.should end_with("\e[0m")
    end
  end

  describe "#failure" do
    it "includes the input text" do
      text = "foobar"
      output = Spectator::Formatting::Color.failure(text)
      output.to_s.should contain(text)
    end

    it "prefixes with green markers" do
      output = Spectator::Formatting::Color.failure("foobar")
      output.to_s.should start_with("\e[31m")
    end

    it "appends color reset markers" do
      output = Spectator::Formatting::Color.failure("foobar")
      output.to_s.should end_with("\e[0m")
    end
  end

  describe "#error" do
    it "includes the input text" do
      text = "foobar"
      output = Spectator::Formatting::Color.error(text)
      output.to_s.should contain(text)
    end

    it "prefixes with green markers" do
      output = Spectator::Formatting::Color.error("foobar")
      output.to_s.should start_with("\e[35m")
    end

    it "appends color reset markers" do
      output = Spectator::Formatting::Color.error("foobar")
      output.to_s.should end_with("\e[0m")
    end
  end

  describe "#pending" do
    it "includes the input text" do
      text = "foobar"
      output = Spectator::Formatting::Color.pending(text)
      output.to_s.should contain(text)
    end

    it "prefixes with green markers" do
      output = Spectator::Formatting::Color.pending("foobar")
      output.to_s.should start_with("\e[33m")
    end

    it "appends color reset markers" do
      output = Spectator::Formatting::Color.pending("foobar")
      output.to_s.should end_with("\e[0m")
    end
  end

  describe "#comment" do
    it "includes the input text" do
      text = "foobar"
      output = Spectator::Formatting::Color.comment(text)
      output.to_s.should contain(text)
    end

    it "prefixes with green markers" do
      output = Spectator::Formatting::Color.comment("foobar")
      output.to_s.should start_with("\e[36m")
    end

    it "appends color reset markers" do
      output = Spectator::Formatting::Color.comment("foobar")
      output.to_s.should end_with("\e[0m")
    end
  end
end
