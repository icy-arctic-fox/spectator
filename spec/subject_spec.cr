require "./spec_helper"

class Base; end

Spectator.describe "Subject" do
  subject { Base.new }

  context "nested" do
    it "inherits the parent explicit subject" do
      expect(subject).to be_a(Base)
    end
  end
end
