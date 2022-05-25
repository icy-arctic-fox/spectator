require "../spec_helper"

class Base; end

module SomeModule; end

Spectator.describe "Subject", :smoke do
  subject { Base.new }

  context "nested" do
    it "inherits the parent explicit subject" do
      expect(subject).to be_a(Base)
    end
  end

  context "module" do
    describe SomeModule do
      it "sets the implicit subject to the module" do
        expect(subject).to be(SomeModule)
      end
    end
  end
end
