require "../../spec_helper"

class Base; end

Spectator.describe "Subject" do
  subject() { Base.new }

  describe "#foo" do
    it "bar" do
      expect(subject).to be_a(Base)
    end
  end
end
