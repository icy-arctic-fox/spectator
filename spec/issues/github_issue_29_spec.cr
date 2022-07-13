require "../spec_helper"

Spectator.describe "GitHub Issue #29" do
  class SomeClass
    def goodbye
      exit 0
    end
  end

  describe SomeClass do
    it "captures exit" do
      expect { subject.goodbye }.to raise_error(Spectator::SystemExit)
    end
  end

  describe "class method" do
    class Foo
      def self.test
        exit 0
      end
    end

    subject { Foo }

    it "must capture exit" do
      expect { subject.test }.to raise_error(Spectator::SystemExit)
    end
  end
end
