require "../spec_helper"

describe Spectator::Expectations::ValueExpectationPartial do
  describe "#actual" do
    context "with a label" do
      it "contains the value passed to the constructor" do
        actual = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(actual.to_s, actual)
        partial.actual.should eq(actual)
      end
    end

    context "without a label" do
      it "contains the value passed to the constructor" do
        actual = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(actual)
        partial.actual.should eq(actual)
      end
    end
  end

  describe "#label" do
    context "when provided" do
      it "contains the value passed to the constructor" do
        actual = 777
        label = "lucky"
        partial = Spectator::Expectations::ValueExpectationPartial.new(label, actual)
        partial.label.should eq(label)
      end
    end

    context "when omitted" do
      it "contains a stringified version of #actual" do
        actual = 777
        partial = Spectator::Expectations::ValueExpectationPartial.new(actual)
        partial.label.should eq(actual.to_s)
      end
    end
  end

  describe "#to" do

  end

  {% for method in [:to_not, :not_to] %}
    describe "{{method.id}}" do

    end
  {% end %}
end
