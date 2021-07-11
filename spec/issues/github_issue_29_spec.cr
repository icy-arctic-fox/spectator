require "../spec_helper"

Spectator.describe "GitHub Issue #29" do
  class SomeClass
    def goodbye
      exit 0
    end
  end

  mock SomeClass do
    stub exit(code)
  end

  describe SomeClass do
    it "captures exit" do
      expect(subject).to receive(:exit).with(0)
      subject.goodbye
    end
  end

  describe "class method" do
    class Foo
      def self.test
        exit 0
      end
    end

    mock Foo do
      stub self.exit(code)
    end

    subject { Foo }

    it "must capture exit" do
      expect(subject).to receive(:exit).with(0)

      subject.test
    end
  end
end
